# This file is used to create the remote backend resources
# These resources are created before the backend configuration is applied
# Comment out or remove this file after the backend is created and properly configured

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "terraform_state" {
  name     = "terraform-state-${random_id.bucket_suffix.hex}"
  location = var.region
  force_destroy = true

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

# Output the bucket name for reference
output "state_bucket_name" {
  description = "The name of the GCS bucket for remote state"
  value       = google_storage_bucket.terraform_state.name
}

# Instructions for updating the backend configuration
output "backend_configuration_instructions" {
  description = "Instructions for configuring the backend"
  value       = <<-EOT
    1. Run 'terraform apply' with this file to create the GCS bucket
    2. Note the state_bucket_name output value
    3. Update backend.tf with the bucket name:

       terraform {
         backend "gcs" {
           bucket = "${google_storage_bucket.terraform_state.name}"
           prefix = "terraform/state"
         }
       }

    4. Run 'terraform init' to initialize the backend
    5. When prompted, select 'yes' to migrate your state to the remote backend
    6. Comment out or remove this file (gcs-setup.tf) to avoid confusion
       or conflicts with the remote backend configuration
  EOT
} 