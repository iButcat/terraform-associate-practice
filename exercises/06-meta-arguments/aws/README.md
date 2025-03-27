# Exercise 6: Resource Meta-Arguments in Terraform (AWS)

## Objectives

In this exercise, you will learn how to use Terraform resource meta-arguments to:

1. Create multiple similar resources with `count`
2. Create resources based on a map with `for_each`
3. Manage resource lifecycle with `lifecycle`
4. Control resource creation order with `depends_on`
5. Use providers for multiple regions with `provider`
6. Prevent resource replacement with `prevent_destroy`

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Completion of previous exercises

## Instructions

### Step 1: Create the Project Structure

Create a new directory for this exercise and set up the following files:

```
meta-arguments/
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

### Step 2: Set Up Basic Configuration

1. Edit `versions.tf` to set required provider versions:
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

2. Edit `variables.tf` to define variables:
   ```hcl
   variable "aws_region" {
     description = "The primary AWS region"
     type        = string
     default     = "us-east-1"
   }
   
   variable "secondary_region" {
     description = "The secondary AWS region"
     type        = string
     default     = "us-west-2"
   }
   
   variable "environment" {
     description = "Environment name"
     type        = string
     default     = "dev"
   }
   
   variable "instance_type" {
     description = "EC2 instance type"
     type        = string
     default     = "t2.micro"
   }
   
   variable "vpc_cidr" {
     description = "CIDR block for the VPC"
     type        = string
     default     = "10.0.0.0/16"
   }
   
   variable "availability_zones" {
     description = "List of availability zones"
     type        = list(string)
     default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
   }
   
   variable "subnet_cidrs" {
     description = "CIDR blocks for the subnets"
     type        = list(string)
     default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
   }
   
   variable "instance_names" {
     description = "Names to assign to instances"
     type        = list(string)
     default     = ["web-1", "web-2", "web-3"]
   }
   
   variable "environments" {
     description = "Map of environment names to configuration"
     type        = map(object({
       instance_type = string
       instance_count = number
     }))
     default     = {
       dev = {
         instance_type = "t2.micro"
         instance_count = 1
       },
       staging = {
         instance_type = "t2.small"
         instance_count = 2
       },
       prod = {
         instance_type = "t2.medium"
         instance_count = 3
       }
     }
   }
   ```

### Step 3: Using `count` Meta-Argument

Edit `main.tf` to add a VPC and subnets using count:

```hcl
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# Subnets using count
resource "aws_subnet" "public" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id

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

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  }
}

# EC2 Instances using count
resource "aws_instance" "web" {
  count                  = length(var.instance_names)
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name        = var.instance_names[count.index]
    Environment = var.environment
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform - Instance ${var.instance_names[count.index]}</h1>" > /var/www/html/index.html
              EOF
}
```

### Step 4: Using `for_each` Meta-Argument

Add resources to `main.tf` using for_each:

```hcl
# S3 Buckets using for_each with a map of settings
resource "aws_s3_bucket" "environments" {
  for_each = var.environments

  bucket = "terraform-meta-args-${var.environment}-${each.key}"

  tags = {
    Name        = "terraform-meta-args-${var.environment}-${each.key}"
    Environment = each.key
    InstanceType = each.value.instance_type
    InstanceCount = each.value.instance_count
  }
}

# Security Groups using for_each with a set
resource "aws_security_group" "environments" {
  for_each    = toset(["web", "app", "db"])
  name        = "${var.environment}-${each.key}-sg"
  description = "Security group for ${each.key} tier"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-${each.key}-sg"
    Environment = var.environment
    Tier        = each.key
  }
}

# Different ingress rules for each security group
resource "aws_security_group_rule" "web_ingress" {
  security_group_id = aws_security_group.environments["web"].id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_ingress" {
  security_group_id = aws_security_group.environments["app"].id
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = aws_security_group.environments["web"].id
}

resource "aws_security_group_rule" "db_ingress" {
  security_group_id = aws_security_group.environments["db"].id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.environments["app"].id
}

# Egress rules for all security groups
resource "aws_security_group_rule" "all_egress" {
  for_each          = aws_security_group.environments
  security_group_id = each.value.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
```

### Step 5: Using `lifecycle` Meta-Argument

Add resources with lifecycle blocks:

```hcl
# Database instance with lifecycle rules
resource "aws_db_instance" "main" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "mydb"
  username             = "admin"
  password             = "temporarypassword" # In production, use a more secure method
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.environments["db"].id]

  tags = {
    Name        = "${var.environment}-db"
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      password, # Ignore changes to the password
      tags["UpdatedAt"] # Ignore changes to the UpdatedAt tag
    ]
    
    prevent_destroy = true # Prevent this resource from being destroyed
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.public[*].id
  
  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Elastic IP with create_before_destroy
resource "aws_eip" "example" {
  vpc = true
  
  tags = {
    Name        = "${var.environment}-eip"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

### Step 6: Using `depends_on` Meta-Argument

Add explicit dependencies:

```hcl
# Explicit dependencies with depends_on
resource "aws_instance" "backend" {
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.environments["app"].id]

  tags = {
    Name        = "${var.environment}-backend"
    Environment = var.environment
  }
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Backend Server</h1>" > /var/www/html/index.html
              EOF

  # This depends_on is explicit but not necessary since subnet_id references the subnet
  # It's included for demonstration purposes
  depends_on = [
    aws_subnet.public,
    aws_internet_gateway.main
  ]
}

# S3 Bucket Policy - depends on bucket
resource "aws_s3_bucket_policy" "environments" {
  for_each = aws_s3_bucket.environments
  bucket   = each.value.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${each.value.arn}/*"
      }
    ]
  })
  
  # Explicitly depends on the bucket
  depends_on = [aws_s3_bucket.environments]
}
```

### Step 7: Multi-Region with `provider` Argument

Configure multiple providers and use the provider argument:

```hcl
# Define a secondary provider
provider "aws" {
  alias  = "west"
  region = var.secondary_region
}

# Resources in the secondary region
resource "aws_vpc" "secondary" {
  provider             = aws.west
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc-secondary"
    Environment = var.environment
  }
}

resource "aws_subnet" "secondary" {
  provider                = aws.west
  vpc_id                  = aws_vpc.secondary.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "${var.secondary_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-subnet-secondary"
    Environment = var.environment
  }
}

resource "aws_instance" "secondary" {
  provider               = aws.west
  ami                    = "ami-0892d3c7ee96c0bf7" # Amazon Linux 2 in us-west-2
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.secondary.id
  
  tags = {
    Name        = "${var.environment}-secondary-instance"
    Environment = var.environment
  }
}
```

### Step 8: Define Outputs

Edit `outputs.tf` to create outputs:

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = aws_subnet.public[*].id
}

output "web_instance_ids" {
  description = "The IDs of the web instances"
  value       = aws_instance.web[*].id
}

output "web_public_ips" {
  description = "The public IPs of the web instances"
  value       = aws_instance.web[*].public_ip
}

output "security_group_ids" {
  description = "The IDs of the security groups created with for_each"
  value       = { for k, v in aws_security_group.environments : k => v.id }
}

output "s3_bucket_names" {
  description = "The names of the S3 buckets created with for_each"
  value       = { for k, v in aws_s3_bucket.environments : k => v.bucket }
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.main.endpoint
}

output "secondary_vpc_id" {
  description = "The ID of the secondary VPC"
  value       = aws_vpc.secondary.id
}

output "secondary_instance_id" {
  description = "The ID of the instance in the secondary region"
  value       = aws_instance.secondary.id
}
```

### Step 9: Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Step 10: Experiment with Meta-Arguments

1. Modify the `instance_names` variable to add or remove names, then run `terraform plan` to see how the count affects resources.

2. Add a new environment to the `environments` map variable and observe how for_each creates a new bucket.

3. Try to destroy the database (`terraform destroy -target=aws_db_instance.main`) and see how `prevent_destroy` stops it.

4. Modify the password in the database resource and observe how `ignore_changes` prevents a replacement.

5. Use `terraform state show` to examine the dependencies between resources.

### Step 11: Clean Up

Before cleaning up, you will need to remove the `prevent_destroy` lifecycle block from the DB instance:

1. Edit the aws_db_instance.main resource to remove or comment out the `prevent_destroy = true` line
2. Run `terraform apply` to update the lifecycle rule
3. Clean up your resources:
   ```bash
   terraform destroy
   ```

## Challenges

1. **Complex Count**: Create a configuration that uses `count` conditionally based on a variable.

2. **Advanced For Each**: Create a more complex structure with `for_each` that uses nested maps or objects.

3. **Custom Module**: Create a module that uses various meta-arguments and call it multiple times with different settings.

4. **Lifecycle Blocks**: Experiment with different lifecycle settings like `replace_triggered_by`.

5. **Provider Configurations**: Set up resources using multiple regions and providers with different configurations.

## Resources

- [Terraform Count Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/count.html)
- [Terraform For Each Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/for_each.html)
- [Terraform Lifecycle Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html)
- [Terraform Depends On Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/depends_on.html)
- [Terraform Provider Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/resource-provider.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) 