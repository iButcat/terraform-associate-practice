# Exercise 2: Variables and Outputs in Terraform (AWS)

## Objective

Learn how to use variables and outputs in Terraform with AWS resources to make configurations more flexible, maintainable, and reusable.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- Completion of Exercise 1: Your First Terraform Configuration (AWS)
- AWS account with appropriate permissions
- AWS CLI configured OR AWS access keys available

## Instructions

### Step 1: Create the Configuration Files

Create a new directory for this exercise and set up the following files:

```bash
mkdir -p terraform-exercises/02-variables-and-outputs
cd terraform-exercises/02-variables-and-outputs
touch main.tf variables.tf outputs.tf versions.tf terraform.tfvars
```

### Step 2: Define Variables

Edit the `variables.tf` file to define variables for your configuration:

```hcl
# Basic variable types
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Number variable
variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

# Boolean variable
variable "enable_public_ip" {
  description = "Whether to assign a public IP to the instance"
  type        = bool
  default     = true
}

# List variable
variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Map variable
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Terraform-Exercise"
  }
}

# Variable with validation
variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

# Object variable
variable "vpc_config" {
  description = "Configuration for the VPC"
  type = object({
    cidr_block           = string
    enable_dns_support   = bool
    enable_dns_hostnames = bool
    subnet_cidrs         = list(string)
  })
  default = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    subnet_cidrs         = ["10.0.1.0/24", "10.0.2.0/24"]
  }
}

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### Step 3: Create the terraform.tfvars File

Edit the `terraform.tfvars` file to set values for your variables:

```hcl
aws_region      = "us-east-1"
instance_name   = "terraform-exercise-instance"
instance_type   = "t2.micro"
instance_count  = 1
enable_public_ip = true
environment     = "dev"
db_password     = "changeme123!"  # In real scenarios, never commit passwords to version control

vpc_config = {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  subnet_cidrs         = ["10.0.1.0/24", "10.0.2.0/24"]
}

tags = {
  Environment = "Development"
  Project     = "Terraform-Exercise"
  Owner       = "Your-Name"
}
```

### Step 4: Define Local Values

Edit the `main.tf` file to define local values:

```hcl
# Define local values
locals {
  # Combine common tags with environment-specific tags
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
  
  # Create subnet names based on count
  subnet_names = [for i in range(length(var.vpc_config.subnet_cidrs)) : "subnet-${i + 1}-${var.environment}"]
  
  # Create a map of AZ to CIDR blocks
  az_to_cidr = zipmap(
    slice(var.availability_zones, 0, length(var.vpc_config.subnet_cidrs)),
    var.vpc_config.subnet_cidrs
  )
  
  # Create a formatted name prefix
  name_prefix = "${var.environment}-${var.instance_name}"
}
```

### Step 5: Define Resources Using Variables and Locals

Continue editing the `main.tf` file to use variables and locals in your resource definitions:

```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_support   = var.vpc_config.enable_dns_support
  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

resource "aws_subnet" "main" {
  count             = length(var.vpc_config.subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_config.subnet_cidrs[count.index]
  availability_zone = element(var.availability_zones, count.index)
  
  tags = merge(
    local.common_tags,
    {
      Name = local.subnet_names[count.index]
    }
  )
}

resource "aws_security_group" "instance" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for instance"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-sg"
    }
  )
}

resource "aws_instance" "app" {
  count                  = var.instance_count
  ami                    = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (adjust as needed)
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main[count.index % length(aws_subnet.main)].id
  vpc_security_group_ids = [aws_security_group.instance.id]
  associate_public_ip_address = var.enable_public_ip
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-${count.index + 1}"
    }
  )
}

# Use sensitive variable (in reality, store this more securely)
resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.environment}/database/password"
  description = "Database password parameter"
  type        = "SecureString"
  value       = var.db_password
  
  tags = local.common_tags
}
```

### Step 6: Define Outputs

Edit the `outputs.tf` file to define outputs that will be displayed after applying the configuration:

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.main[*].id
}

output "subnet_cidr_blocks" {
  description = "CIDR blocks of the created subnets"
  value       = aws_subnet.main[*].cidr_block
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.instance.id
}

output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = aws_instance.app[*].id
}

output "instance_public_ips" {
  description = "Public IPs of the created EC2 instances"
  value       = aws_instance.app[*].public_ip
}

# Formatted output using functions
output "resource_summary" {
  description = "Summary of created resources"
  value = format(
    "Created VPC %s with %d subnet(s) and %d instance(s) in %s environment",
    aws_vpc.main.id,
    length(aws_subnet.main),
    length(aws_instance.app),
    var.environment
  )
}

# Output with sensitive value
output "password_parameter_name" {
  description = "Name of the SSM parameter storing the database password"
  value       = aws_ssm_parameter.db_password.name
}

# Sensitive output
output "db_password" {
  description = "The database password (sensitive)"
  value       = var.db_password
  sensitive   = true
}

# Conditional output
output "environment_info" {
  description = "Environment information"
  value       = var.environment == "prod" ? "Production environment - handle with care" : "Non-production environment (${var.environment})"
}

# Output using for expression
output "subnet_details" {
  description = "Map of subnet IDs to CIDR blocks"
  value       = { for subnet in aws_subnet.main : subnet.id => subnet.cidr_block }
}
```

### Step 7: Set Up Versions Constraints

Edit the `versions.tf` file to define provider and Terraform versions:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  required_version = ">= 1.0.0"
}
```

### Step 8: Initialize and Apply the Configuration

```bash
terraform init
terraform plan
terraform apply
```

### Step 9: Experiment with Variable Values

Try changing variable values to see how it affects your configuration:

1. Edit the `terraform.tfvars` file to change values:
   ```hcl
   instance_count = 2
   environment    = "test"
   ```

2. Apply the changes:
   ```bash
   terraform apply
   ```

3. Observe how the changes in variables affect resources and outputs.

### Step 10: Use Variable Overrides

Try overriding variables using command-line flags:

```bash
terraform apply -var="instance_count=3" -var="environment=prod"
```

### Step 11: Use a Different Variable File

Create a production-specific variable file:

```bash
touch prod.tfvars
```

Edit `prod.tfvars`:
```hcl
environment     = "prod"
instance_count  = 2
instance_type   = "t3.small"
enable_public_ip = false
tags = {
  Environment = "Production"
  Project     = "Terraform-Exercise"
  Owner       = "Your-Name"
  CostCenter  = "123456"
}
```

Apply with the production variable file:
```bash
terraform apply -var-file="prod.tfvars"
```

### Step 12: Clean Up

Destroy the resources to avoid charges:

```bash
terraform destroy
```

## Additional Challenges

1. Add a tuple variable type to represent a fixed-length collection with different element types
2. Implement more complex validation rules, such as regex pattern matching for string variables
3. Create a map of maps for more complex resource configurations
4. Use the `templatefile` function to generate a configuration file from a template
5. Implement dynamic blocks for security group rules based on variable inputs

## Solution

See the [solution directory](./solution) for a complete working example.

## Key Learnings

- Variables make Terraform configurations flexible and reusable
- Different variable types serve different purposes
- Variables can have default values and validation rules
- Local values help reduce repetition and compute derived values
- Variables can be provided through multiple methods with a specific precedence
- Outputs extract useful information about created resources
- Functions and expressions can manipulate variable values and format outputs
- Using variables effectively makes configurations more maintainable and adaptable 