# Basic variable types
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for resources that require a zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Base name for the VM instances"
  type        = string
  default     = "terraform-exercise-instance"
}

variable "instance_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-micro"
}

# Number variable
variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

# Boolean variable
variable "enable_public_ip" {
  description = "Whether to assign a public IP to the instances"
  type        = bool
  default     = true
}

# List variable
variable "zones" {
  description = "List of zones to use for resources"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

# Map variable
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    environment = "development"
    project     = "terraform-exercise"
    managed_by  = "terraform"
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
variable "network_config" {
  description = "Configuration for the VPC network"
  type = object({
    network_name         = string
    auto_create_subnets  = bool
    subnet_name          = string
    subnet_ip_cidr_range = string
    subnet_region        = string
  })
  default = {
    network_name         = "terraform-network"
    auto_create_subnets  = false
    subnet_name          = "terraform-subnet"
    subnet_ip_cidr_range = "10.0.1.0/24"
    subnet_region        = "us-central1"
  }
}

# Tuple variable
variable "instance_settings" {
  description = "Settings for VM instances as a tuple of [image, machine_type, boot_disk_size]"
  type        = tuple([string, string, number])
  default     = ["debian-cloud/debian-11", "e2-micro", 10]
}

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "changeme123!" # In real scenarios, never store passwords in your code
}

# Variable with complex validation
variable "allowed_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
  default     = [22, 80, 443]

  validation {
    condition     = alltrue([for port in var.allowed_ports : port > 0 && port < 65536])
    error_message = "All ports must be between 1 and 65535."
  }
}

# Map of objects variable
variable "additional_subnets" {
  description = "Additional subnets to create"
  type = map(object({
    cidr_range = string
    region     = string
    private    = bool
  }))
  default = {
    "additional-subnet-1" = {
      cidr_range = "10.0.2.0/24"
      region     = "us-central1"
      private    = true
    },
    "additional-subnet-2" = {
      cidr_range = "10.0.3.0/24"
      region     = "us-central1"
      private    = false
    }
  }
} 