variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for multi-region resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "development"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 3

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

variable "developer_names" {
  description = "List of developer IAM users to create"
  type        = list(string)
  default     = ["dev1", "dev2", "dev3"]
}

variable "bucket_names" {
  description = "List of S3 bucket names to create"
  type        = list(string)
  default     = ["data-bucket-1", "data-bucket-2", "data-bucket-3"]
}

variable "operator_roles" {
  description = "Map of operator names to their roles and teams"
  type = map(object({
    role = string
    team = string
  }))
  default = {
    "op1" = {
      role = "SysAdmin"
      team = "Infrastructure"
    },
    "op2" = {
      role = "DevOps"
      team = "Platform"
    }
  }
}

variable "vpc_config" {
  description = "VPC configuration settings"
  type = object({
    cidr_block = string
    subnet_cidrs = list(string)
    enable_dns_hostnames = bool
  })
  default = {
    cidr_block = "10.0.0.0/16"
    subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
    enable_dns_hostnames = true
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI ID
}

variable "db_config" {
  description = "RDS database configuration"
  type = object({
    identifier = string
    engine = string
    engine_version = string
    instance_class = string
    allocated_storage = number
    db_name = string
    username = string
    password = string
  })
  default = {
    identifier = "example"
    engine = "postgres"
    engine_version = "13.7"
    instance_class = "db.t3.micro"
    allocated_storage = 20
    db_name = "example"
    username = "admin"
    password = "example-password"
  }

  validation {
    condition     = var.db_config.allocated_storage >= 20
    error_message = "Allocated storage must be at least 20GB."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "terraform-learning"
    Environment = "development"
    Terraform   = "true"
  }
} 