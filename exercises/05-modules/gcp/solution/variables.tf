variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
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
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "zones" {
  description = "Zones for instance deployment"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
} 