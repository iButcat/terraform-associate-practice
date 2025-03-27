variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for instances"
  type        = string
  default     = "e2-micro"
}

variable "image" {
  description = "Image for instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "zones" {
  description = "Zones for instances"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b"]
}

variable "vpc_self_link" {
  description = "Self link of the VPC"
  type        = string
}

variable "subnet_self_links" {
  description = "Self links of the subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 