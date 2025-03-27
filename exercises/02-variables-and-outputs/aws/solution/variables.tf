# Basic variable types
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "terraform-exercise-instance"
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
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Map variable
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "Terraform-Exercise"
    ManagedBy   = "Terraform"
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

# Tuple variable
variable "instance_settings" {
  description = "Settings for EC2 instances as a tuple of [ami, instance_type, monitoring]"
  type        = tuple([string, string, bool])
  default     = ["ami-0c55b159cbfafe1f0", "t2.micro", false]
}

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "changeme123!" # In real scenarios, never store passwords in your code
}

# Variable with complex validation
variable "allowed_ingress_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
  default     = [22, 80, 443]

  validation {
    condition     = alltrue([for port in var.allowed_ingress_ports : port > 0 && port < 65536])
    error_message = "All ports must be between 1 and 65535."
  }
} 