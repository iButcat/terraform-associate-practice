# Exercise 5: Modules in Terraform (AWS)

## Objectives

In this exercise, you will learn how to:

1. Create reusable Terraform modules
2. Organize modules with proper structure and documentation
3. Pass inputs to modules and use module outputs
4. Use modules to create a multi-tier application infrastructure
5. Reference public modules from the Terraform Registry

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Completion of previous exercises

## Instructions

### Step 1: Understand Modules

Terraform modules are containers for multiple resources that are used together. They help with:
- Code organization and reusability
- Encapsulation and abstraction
- Consistent configurations
- Separation of concerns

### Step 2: Create a Module Structure

1. Create the following directory structure:
   ```
   modules/
   ├── vpc/
   │   ├── main.tf
   │   ├── variables.tf
   │   ├── outputs.tf
   │   └── README.md
   ├── web/
   │   ├── main.tf
   │   ├── variables.tf
   │   ├── outputs.tf
   │   └── README.md
   └── db/
       ├── main.tf
       ├── variables.tf
       ├── outputs.tf
       └── README.md
   ```

2. In the root of your project, create:
   ```
   main.tf
   variables.tf
   outputs.tf
   versions.tf
   ```

### Step 3: Create the VPC Module

1. Edit `modules/vpc/variables.tf` to define input variables:
   ```hcl
   variable "vpc_cidr" {
     description = "CIDR block for the VPC"
     type        = string
     default     = "10.0.0.0/16"
   }
   
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "public_subnets" {
     description = "CIDR blocks for public subnets"
     type        = list(string)
     default     = ["10.0.1.0/24", "10.0.2.0/24"]
   }
   
   variable "private_subnets" {
     description = "CIDR blocks for private subnets"
     type        = list(string)
     default     = ["10.0.3.0/24", "10.0.4.0/24"]
   }
   
   variable "availability_zones" {
     description = "Availability zones to use"
     type        = list(string)
     default     = ["us-east-1a", "us-east-1b"]
   }
   
   variable "tags" {
     description = "Tags to apply to resources"
     type        = map(string)
     default     = {}
   }
   ```

2. Edit `modules/vpc/main.tf` to create VPC resources:
   ```hcl
   resource "aws_vpc" "main" {
     cidr_block           = var.vpc_cidr
     enable_dns_support   = true
     enable_dns_hostnames = true
     
     tags = merge(
       {
         Name        = "${var.environment}-vpc"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_subnet" "public" {
     count                   = length(var.public_subnets)
     vpc_id                  = aws_vpc.main.id
     cidr_block              = var.public_subnets[count.index]
     availability_zone       = element(var.availability_zones, count.index)
     map_public_ip_on_launch = true
     
     tags = merge(
       {
         Name        = "${var.environment}-public-subnet-${count.index + 1}"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_subnet" "private" {
     count             = length(var.private_subnets)
     vpc_id            = aws_vpc.main.id
     cidr_block        = var.private_subnets[count.index]
     availability_zone = element(var.availability_zones, count.index)
     
     tags = merge(
       {
         Name        = "${var.environment}-private-subnet-${count.index + 1}"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_internet_gateway" "main" {
     vpc_id = aws_vpc.main.id
     
     tags = merge(
       {
         Name        = "${var.environment}-igw"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_route_table" "public" {
     vpc_id = aws_vpc.main.id
     
     route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main.id
     }
     
     tags = merge(
       {
         Name        = "${var.environment}-public-route-table"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_route_table_association" "public" {
     count          = length(var.public_subnets)
     subnet_id      = aws_subnet.public[count.index].id
     route_table_id = aws_route_table.public.id
   }
   
   resource "aws_route_table" "private" {
     vpc_id = aws_vpc.main.id
     
     tags = merge(
       {
         Name        = "${var.environment}-private-route-table"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_route_table_association" "private" {
     count          = length(var.private_subnets)
     subnet_id      = aws_subnet.private[count.index].id
     route_table_id = aws_route_table.private.id
   }
   ```

3. Edit `modules/vpc/outputs.tf` to define outputs:
   ```hcl
   output "vpc_id" {
     description = "The ID of the VPC"
     value       = aws_vpc.main.id
   }
   
   output "vpc_cidr" {
     description = "The CIDR block of the VPC"
     value       = aws_vpc.main.cidr_block
   }
   
   output "public_subnet_ids" {
     description = "List of public subnet IDs"
     value       = aws_subnet.public[*].id
   }
   
   output "private_subnet_ids" {
     description = "List of private subnet IDs"
     value       = aws_subnet.private[*].id
   }
   
   output "public_route_table_id" {
     description = "ID of the public route table"
     value       = aws_route_table.public.id
   }
   
   output "private_route_table_id" {
     description = "ID of the private route table"
     value       = aws_route_table.private.id
   }
   ```

### Step 4: Create the Web Module

1. Edit `modules/web/variables.tf`:
   ```hcl
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "vpc_id" {
     description = "VPC ID"
     type        = string
   }
   
   variable "subnet_ids" {
     description = "List of subnet IDs"
     type        = list(string)
   }
   
   variable "instance_count" {
     description = "Number of instances to create"
     type        = number
     default     = 1
   }
   
   variable "ami_id" {
     description = "AMI ID to use for instances"
     type        = string
     default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
   }
   
   variable "instance_type" {
     description = "Instance type"
     type        = string
     default     = "t2.micro"
   }
   
   variable "tags" {
     description = "Tags to apply to resources"
     type        = map(string)
     default     = {}
   }
   ```

2. Edit `modules/web/main.tf`:
   ```hcl
   resource "aws_security_group" "web" {
     name        = "${var.environment}-web-sg"
     description = "Security group for web servers"
     vpc_id      = var.vpc_id
     
     ingress {
       from_port   = 80
       to_port     = 80
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
       description = "HTTP from anywhere"
     }
     
     ingress {
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
       description = "SSH from anywhere"
     }
     
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
     
     tags = merge(
       {
         Name        = "${var.environment}-web-sg"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_instance" "web" {
     count                  = var.instance_count
     ami                    = var.ami_id
     instance_type          = var.instance_type
     subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids))
     vpc_security_group_ids = [aws_security_group.web.id]
     
     user_data = <<-EOF
                 #!/bin/bash
                 yum update -y
                 yum install -y httpd
                 systemctl start httpd
                 systemctl enable httpd
                 echo "<h1>Hello from Terraform Module (Instance ${count.index + 1})</h1>" > /var/www/html/index.html
                 EOF
     
     tags = merge(
       {
         Name        = "${var.environment}-web-${count.index + 1}"
         Environment = var.environment
       },
       var.tags
     )
   }
   ```

3. Edit `modules/web/outputs.tf`:
   ```hcl
   output "security_group_id" {
     description = "The ID of the web security group"
     value       = aws_security_group.web.id
   }
   
   output "instance_ids" {
     description = "List of instance IDs"
     value       = aws_instance.web[*].id
   }
   
   output "public_ips" {
     description = "List of public IP addresses"
     value       = aws_instance.web[*].public_ip
   }
   ```

### Step 5: Create the DB Module

1. Edit `modules/db/variables.tf`:
   ```hcl
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "vpc_id" {
     description = "VPC ID"
     type        = string
   }
   
   variable "subnet_ids" {
     description = "List of subnet IDs"
     type        = list(string)
   }
   
   variable "allowed_security_group_ids" {
     description = "List of security group IDs that can access the database"
     type        = list(string)
   }
   
   variable "database_name" {
     description = "Name of the database"
     type        = string
     default     = "appdb"
   }
   
   variable "username" {
     description = "Database username"
     type        = string
     default     = "admin"
   }
   
   variable "password" {
     description = "Database password"
     type        = string
     sensitive   = true
   }
   
   variable "instance_class" {
     description = "Database instance class"
     type        = string
     default     = "db.t2.micro"
   }
   
   variable "tags" {
     description = "Tags to apply to resources"
     type        = map(string)
     default     = {}
   }
   ```

2. Edit `modules/db/main.tf`:
   ```hcl
   resource "aws_security_group" "db" {
     name        = "${var.environment}-db-sg"
     description = "Security group for database"
     vpc_id      = var.vpc_id
     
     ingress {
       from_port       = 3306
       to_port         = 3306
       protocol        = "tcp"
       security_groups = var.allowed_security_group_ids
       description     = "MySQL from web tier"
     }
     
     egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
     }
     
     tags = merge(
       {
         Name        = "${var.environment}-db-sg"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_db_subnet_group" "db" {
     name        = "${var.environment}-db-subnet-group"
     subnet_ids  = var.subnet_ids
     description = "DB subnet group for ${var.environment}"
     
     tags = merge(
       {
         Name        = "${var.environment}-db-subnet-group"
         Environment = var.environment
       },
       var.tags
     )
   }
   
   resource "aws_db_instance" "db" {
     identifier             = "${var.environment}-db"
     allocated_storage      = 10
     engine                 = "mysql"
     engine_version         = "5.7"
     instance_class         = var.instance_class
     db_name                = var.database_name
     username               = var.username
     password               = var.password
     parameter_group_name   = "default.mysql5.7"
     vpc_security_group_ids = [aws_security_group.db.id]
     db_subnet_group_name   = aws_db_subnet_group.db.name
     skip_final_snapshot    = true
     
     tags = merge(
       {
         Name        = "${var.environment}-db"
         Environment = var.environment
       },
       var.tags
     )
   }
   ```

3. Edit `modules/db/outputs.tf`:
   ```hcl
   output "endpoint" {
     description = "The database endpoint"
     value       = aws_db_instance.db.endpoint
   }
   
   output "security_group_id" {
     description = "The ID of the database security group"
     value       = aws_security_group.db.id
   }
   
   output "db_instance_id" {
     description = "The ID of the database instance"
     value       = aws_db_instance.db.id
   }
   ```

### Step 6: Create Root Module Configuration

1. Edit `variables.tf` in the root directory:
   ```hcl
   variable "aws_region" {
     description = "AWS region to deploy resources"
     type        = string
     default     = "us-east-1"
   }
   
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "vpc_cidr" {
     description = "CIDR block for the VPC"
     type        = string
     default     = "10.0.0.0/16"
   }
   
   variable "db_password" {
     description = "Database password"
     type        = string
     sensitive   = true
   }
   ```

2. Edit `main.tf` in the root directory:
   ```hcl
   provider "aws" {
     region = var.aws_region
   }
   
   module "vpc" {
     source = "./modules/vpc"
     
     vpc_cidr          = var.vpc_cidr
     environment       = var.environment
     public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
     private_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
     availability_zones = ["us-east-1a", "us-east-1b"]
     
     tags = {
       Project = "terraform-modules-exercise"
     }
   }
   
   module "web" {
     source = "./modules/web"
     
     environment    = var.environment
     vpc_id         = module.vpc.vpc_id
     subnet_ids     = module.vpc.public_subnet_ids
     instance_count = 2
     
     tags = {
       Project = "terraform-modules-exercise"
     }
   }
   
   module "db" {
     source = "./modules/db"
     
     environment               = var.environment
     vpc_id                    = module.vpc.vpc_id
     subnet_ids                = module.vpc.private_subnet_ids
     allowed_security_group_ids = [module.web.security_group_id]
     database_name             = "appdb"
     username                  = "admin"
     password                  = var.db_password
     
     tags = {
       Project = "terraform-modules-exercise"
     }
   }
   ```

3. Edit `outputs.tf` in the root directory:
   ```hcl
   output "vpc_id" {
     description = "The ID of the VPC"
     value       = module.vpc.vpc_id
   }
   
   output "public_subnet_ids" {
     description = "The IDs of the public subnets"
     value       = module.vpc.public_subnet_ids
   }
   
   output "private_subnet_ids" {
     description = "The IDs of the private subnets"
     value       = module.vpc.private_subnet_ids
   }
   
   output "web_instance_ids" {
     description = "The IDs of the web instances"
     value       = module.web.instance_ids
   }
   
   output "web_public_ips" {
     description = "The public IPs of the web instances"
     value       = module.web.public_ips
   }
   
   output "db_endpoint" {
     description = "The endpoint of the database"
     value       = module.db.endpoint
   }
   ```

4. Edit `versions.tf` in the root directory:
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

### Step 7: Use the Public Registry Module

1. Add an S3 module using the official AWS S3 module from the Registry:
   ```hcl
   module "s3_bucket" {
     source  = "terraform-aws-modules/s3-bucket/aws"
     version = "3.0.1"
     
     bucket = "terraform-modules-exercise-${random_string.bucket_suffix.result}"
     acl    = "private"
     
     versioning = {
       enabled = true
     }
     
     tags = {
       Name        = "${var.environment}-assets"
       Environment = var.environment
       Project     = "terraform-modules-exercise"
     }
   }
   
   resource "random_string" "bucket_suffix" {
     length  = 8
     special = false
     upper   = false
   }
   ```

2. Add the random provider to `versions.tf`:
   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 4.0"
       }
       random = {
         source  = "hashicorp/random"
         version = "~> 3.0"
       }
     }
     required_version = ">= 1.0.0"
   }
   ```

3. Add an output for the S3 bucket:
   ```hcl
   output "s3_bucket_name" {
     description = "The name of the S3 bucket"
     value       = module.s3_bucket.s3_bucket_id
   }
   ```

### Step 8: Apply the Configuration

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Create a `terraform.tfvars` file:
   ```hcl
   aws_region   = "us-east-1"
   environment  = "dev"
   vpc_cidr     = "10.0.0.0/16"
   db_password  = "YourStrongPassword123!"  # In production, use a more secure method
   ```

3. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

4. Verify the created resources in the AWS Console.

### Step 9: Module Documentation

1. Create a README.md file for each module to document:
   - Purpose of the module
   - Required and optional inputs
   - Outputs
   - Example usage

For example, `modules/vpc/README.md`:
```markdown
# VPC Module

This module creates a VPC with public and private subnets in specified availability zones.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| environment | Environment name | `string` | `"dev"` | no |
| public_subnets | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| private_subnets | CIDR blocks for private subnets | `list(string)` | `["10.0.3.0/24", "10.0.4.0/24"]` | no |
| availability_zones | Availability zones to use | `list(string)` | `["us-east-1a", "us-east-1b"]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| public_route_table_id | ID of the public route table |
| private_route_table_id | ID of the private route table |

## Example Usage

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr          = "10.0.0.0/16"
  environment       = "prod"
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  tags = {
    Project = "my-project"
  }
}
```
```

### Step 10: Clean Up

When you're done, destroy the resources:
```bash
terraform destroy
```

## Challenges

1. **Module Composition**: Create a "database" module that composes multiple resources, including RDS instances, security groups, and parameter groups.

2. **Conditional Resources**: Modify the web module to conditionally create an Application Load Balancer if the instance count is greater than 1.

3. **Module Versioning**: Set up a simple Git repository to manage your modules and use Git references to version them.

4. **Multiple Environments**: Use your modules to create multiple environments (dev, test, prod) with different configurations.

5. **External Data**: Modify the EC2 module to pull AMI IDs from AWS SSM Parameter Store using a data source.

## Resources

- [Terraform Module Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [Module Development](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Terraform Registry](https://registry.terraform.io/browse/modules)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Module Composition](https://www.terraform.io/docs/language/modules/develop/composition.html) 