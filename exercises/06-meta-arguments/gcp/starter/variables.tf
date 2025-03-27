variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "primary_region" {
  description = "The primary GCP region"
  type        = string
  default     = "us-central1"
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