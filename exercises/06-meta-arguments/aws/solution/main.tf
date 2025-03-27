# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Configure a secondary provider for multi-region resources
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region

  default_tags {
    tags = var.common_tags
  }
}

# Create a VPC using variable object
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames

  tags = {
    Name = "main-vpc"
  }
}

# Create multiple subnets using count
resource "aws_subnet" "main" {
  count             = length(var.vpc_config.subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vpc_config.subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "subnet-${count.index + 1}"
  }

  depends_on = [aws_vpc.main]
}

# Create multiple EC2 instances using count
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main[count.index % length(aws_subnet.main)].id

  tags = {
    Name = "web-server-${count.index + 1}"
  }

  depends_on = [aws_subnet.main]
}

# Create multiple IAM users using for_each with a set
resource "aws_iam_user" "developers" {
  for_each = toset(var.developer_names)
  name     = each.key

  tags = {
    Role = "Developer"
  }
}

# Create multiple S3 buckets using for_each with a map
resource "aws_s3_bucket" "data" {
  for_each = toset(var.bucket_names)
  bucket   = each.key

  # Create new bucket before destroying old one
  lifecycle {
    create_before_destroy = true
  }
}

# Create operator IAM users with roles using for_each
resource "aws_iam_user" "operators" {
  for_each = var.operator_roles
  name     = each.key

  tags = {
    Role = each.value.role
    Team = each.value.team
  }
}

# Create an RDS instance with lifecycle rules
resource "aws_db_instance" "main" {
  identifier        = var.db_config.identifier
  engine            = var.db_config.engine
  engine_version    = var.db_config.engine_version
  instance_class    = var.db_config.instance_class
  allocated_storage = var.db_config.allocated_storage

  db_name  = var.db_config.db_name
  username = var.db_config.username
  password = var.db_config.password

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_vpc.main]
}

# Create a security group with dynamic blocks
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Web server security group"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Ignore changes to tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Create a multi-region S3 bucket using the secondary provider
resource "aws_s3_bucket" "backup" {
  provider = aws.secondary
  bucket   = "backup-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for security group rules
locals {
  ingress_rules = {
    http = {
      description = "HTTP"
      port        = 80
    }
    https = {
      description = "HTTPS"
      port        = 443
    }
    ssh = {
      description = "SSH"
      port        = 22
    }
  }
} 