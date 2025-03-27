variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "storage_class" {
  description = "Storage class for buckets"
  type        = string
  default     = "STANDARD"
}

variable "bucket_location" {
  description = "Location for buckets"
  type        = string
  default     = "US"
}

variable "bucket_name" {
  description = "Base name for bucket"
  type        = string
  default     = "terraform-module-storage"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
} 