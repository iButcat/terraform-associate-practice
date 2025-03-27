aws_region      = "us-east-1"
instance_name   = "terraform-exercise-instance"
instance_type   = "t2.micro"
instance_count  = 2
enable_public_ip = true
environment     = "dev"
db_password     = "changeme123!" # In real scenarios, never commit passwords to version control

availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]

vpc_config = {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  subnet_cidrs         = ["10.0.1.0/24", "10.0.2.0/24"]
}

tags = {
  Environment = "Development"
  Project     = "Terraform-Exercise"
  Owner       = "Your-Name"
  ManagedBy   = "Terraform"
}

instance_settings = ["ami-0c55b159cbfafe1f0", "t2.micro", true]

allowed_ingress_ports = [22, 80, 443, 8080] 