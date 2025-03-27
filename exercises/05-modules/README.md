# Exercise 5: Working with Terraform Modules

## Objective
Learn how to create, use, and manage Terraform modules, including module sources, versioning, and best practices for module organization.

## Prerequisites
- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- Basic understanding of Terraform configuration from previous exercises

## Step-by-Step Instructions

### Step 1: Create the Module Structure

Create the following directory structure:

```bash
mkdir -p terraform-exercises/05-modules
cd terraform-exercises/05-modules
mkdir -p modules/{vpc,ec2,rds}
```

### Step 2: Create the VPC Module

1. Create `modules/vpc/main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  map_public_ip_on_launch = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-${count.index + 1}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-private-${count.index + 1}"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-igw"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-public-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

2. Create `modules/vpc/variables.tf`:

```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

3. Create `modules/vpc/outputs.tf`:

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}
```

### Step 3: Create the EC2 Module

1. Create `modules/ec2/main.tf`:

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
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-web-sg"
    }
  )
}

resource "aws_instance" "web" {
  count = var.instance_count
  
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index % length(var.subnet_ids)]
  
  vpc_security_group_ids = [aws_security_group.web.id]
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-web-${count.index + 1}"
    }
  )
}
```

2. Create `modules/ec2/variables.tf`:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
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
  description = "AMI ID for EC2 instances"
  type        = string
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

3. Create `modules/ec2/outputs.tf`:

```hcl
output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.web[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}
```

### Step 4: Create the RDS Module

1. Create `modules/rds/main.tf`:

```hcl
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-db-sg"
    }
  )
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-db-subnet-group"
    }
  )
}

resource "aws_db_instance" "main" {
  identifier           = "${var.environment}-db"
  engine              = "postgres"
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  storage_type        = "gp2"
  
  db_name  = var.database_name
  username = var.username
  password = var.password
  
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  skip_final_snapshot = true
  
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-db"
    }
  )
}
```

2. Create `modules/rds/variables.tf`:

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
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
  description = "List of security group IDs allowed to access the database"
  type        = list(string)
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "13.7"
}

variable "instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}

variable "username" {
  description = "Database username"
  type        = string
}

variable "password" {
  description = "Database password"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

3. Create `modules/rds/outputs.tf`:

```hcl
output "endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.db.id
}
```

### Step 5: Create the Root Configuration

1. Create `main.tf`:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "10.0.0.0/16"
  environment        = "dev"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  tags = {
    Environment = "dev"
    Project     = "learning"
  }
}

module "web" {
  source = "./modules/ec2"
  
  environment    = "dev"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  instance_count = 2
  ami_id         = "ami-0c55b159cbfafe1f0"
  instance_type  = "t2.micro"
  
  tags = {
    Environment = "dev"
    Project     = "learning"
  }
}

module "db" {
  source = "./modules/rds"
  
  environment                = "dev"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.web.security_group_id]
  
  database_name = "example"
  username      = "admin"
  password      = "example-password"  # In production, use variables and secrets management
  
  tags = {
    Environment = "dev"
    Project     = "learning"
  }
}
```

2. Create `outputs.tf`:

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "web_instance_ids" {
  description = "List of web server instance IDs"
  value       = module.web.instance_ids
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.db.endpoint
}
```

3. Create `versions.tf`:

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

### Step 6: Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Step 7: Test Module Outputs

```bash
terraform output
```

### Step 8: Clean Up

```bash
terraform destroy
```

## Additional Challenges

1. Add a module for creating an Application Load Balancer
2. Create a module for S3 bucket with versioning and encryption
3. Implement a module for CloudWatch monitoring
4. Create a module for Lambda functions
5. Add module versioning using Git tags

## Solution

See the [solution](./solution) directory for a complete working example.

## Key Learnings

- Modules help organize and reuse Terraform code
- Module structure and organization best practices
- Input variables and output values in modules
- Module versioning and source types
- Local vs remote modules
- Module composition and dependencies
- Using count and for_each with modules
- Module documentation and examples 