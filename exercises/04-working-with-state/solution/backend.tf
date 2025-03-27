terraform {
  backend "s3" {
    bucket         = "terraform-state-example-1234"  # Replace with your bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
} 