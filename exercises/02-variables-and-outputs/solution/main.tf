provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.cidr_block
  enable_dns_support   = var.vpc_config.enable_dns_support
  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
  
  tags = merge(
    var.tags,
    {
      Name = "main-vpc-${var.environment}"
    }
  )
}

resource "aws_subnet" "main" {
  count             = var.instance_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = element(var.availability_zones, count.index)
  
  tags = merge(
    var.tags,
    {
      Name = "subnet-${count.index + 1}-${var.environment}"
    }
  )
}

resource "aws_security_group" "instance" {
  name        = "instance-sg-${var.environment}"
  description = "Security group for instance"
  vpc_id      = aws_vpc.main.id
  
  # Dynamic blocks for ingress rules based on allowed_ports variable
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
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
      Name = "sg-${var.environment}"
    }
  )
}

# Use sensitive variable (in reality, store this more securely)
resource "aws_ssm_parameter" "db_password" {
  name        = "/database/password/${var.environment}"
  description = "Database password parameter"
  type        = "SecureString"
  value       = var.db_password
  
  tags = var.tags
}

# Local values demonstration
locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "Terraform"
      CreatedAt = timestamp()
    }
  )
  
  is_production = var.environment == "prod"
  
  subnet_ids = aws_subnet.main[*].id
}

# Conditional resource creation
resource "aws_eip" "instance" {
  count = var.enable_public_ip ? var.instance_count : 0
  
  tags = local.common_tags
} 