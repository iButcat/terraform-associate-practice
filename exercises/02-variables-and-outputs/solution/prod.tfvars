environment    = "prod"
instance_count = 2
instance_type  = "t3.micro"

tags = {
  Environment = "Production"
  Project     = "Terraform-Exercise"
  Owner       = "DevOps-Team"
  CostCenter  = "CC-123"
}

vpc_config = {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
} 