terraform {
  backend "s3" {
    # These values must be configured via terraform init -backend-config parameters
    # or stored in a separate file passed to terraform init with -backend-config="file.tfbackend"
    bucket         = "REPLACE_WITH_YOUR_BUCKET_NAME" # Will be replaced during initialization
    key            = "terraform/state/exercise-4"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

# This is an example of a partial backend configuration file (terraform.tfbackend)
# that you would use with terraform init -backend-config="terraform.tfbackend"
# 
# bucket = "terraform-state-XXXXXX"
# region = "us-east-1"
# dynamodb_table = "terraform-state-locks"
# encrypt = true 