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

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Object variable
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
    enable_dns_support = bool
    enable_dns_hostnames = bool
  })
  default = {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
  }
}

# Tuple variable example
variable "allowed_ports" {
  description = "List of allowed ports and protocols"
  type = list(object({
    port = number
    protocol = string
    description = string
  }))
  default = [
    {
      port = 22
      protocol = "tcp"
      description = "SSH access"
    },
    {
      port = 80
      protocol = "tcp"
      description = "HTTP access"
    },
    {
      port = 443
      protocol = "tcp"
      description = "HTTPS access"
    }
  ]
} 