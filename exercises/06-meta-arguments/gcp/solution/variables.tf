variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "primary_region" {
  description = "The primary GCP region"
  type        = string
  default     = "us-central1"
}

variable "secondary_region" {
  description = "The secondary GCP region"
  type        = string
  default     = "us-west1"
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "machine_type" {
  description = "The GCP machine type"
  type        = string
  default     = "e2-micro"
}

variable "db_machine_type" {
  description = "The database machine type"
  type        = string
  default     = "db-f1-micro"
}

variable "zones" {
  description = "List of zones for instance deployment"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "instance_names" {
  description = "Names to assign to instances"
  type        = list(string)
  default     = ["web-1", "web-2", "web-3"]
}

variable "environments" {
  description = "Map of environments to settings"
  type = map(object({
    location       = string
    instance_type  = string
    instance_count = number
  }))
  default = {
    dev = {
      location       = "US-CENTRAL1"
      instance_type  = "e2-micro"
      instance_count = 1
    },
    staging = {
      location       = "US-EAST1"
      instance_type  = "e2-small"
      instance_count = 2
    },
    prod = {
      location       = "US-WEST1"
      instance_type  = "e2-medium"
      instance_count = 3
    }
  }
}

variable "enable_secondary_region" {
  description = "Whether to create resources in the secondary region"
  type        = bool
  default     = true
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "The database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The database password"
  type        = string
  default     = "ChangeMe123!"
  sensitive   = true
} 