provider "aws" {
  region = var.aws_region
}

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
  
  # Dynamic security group rule configuration
  sg_rules = {
    for port in var.allowed_ingress_ports : 
    "rule-${port}" => {
      from_port   = port
      to_port     = port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow traffic on port ${port}"
    }
  }
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

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-route-table"
    }
  )
}

resource "aws_route_table_association" "main" {
  count          = length(aws_subnet.main)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "instance" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for instance"
  vpc_id      = aws_vpc.main.id
  
  # Dynamic block for ingress rules
  dynamic "ingress" {
    for_each = local.sg_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
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
  ami                    = var.instance_settings[0]
  instance_type          = var.instance_settings[1]
  monitoring             = var.instance_settings[2]
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