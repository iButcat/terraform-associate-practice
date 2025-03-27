terraform {
  backend "gcs" {
    bucket = "REPLACE_WITH_YOUR_BUCKET_NAME" # Replace with your actual bucket name
    prefix = "terraform/state"
  }
} 