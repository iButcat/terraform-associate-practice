aws_region     = "us-east-1"
instance_name  = "terraform-exercise-instance"
instance_type  = "t2.micro"
instance_count = 1
enable_public_ip = true
environment    = "dev"
db_password    = "changeme123!"  # In real scenarios, never commit passwords to version control

vpc_config = {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
} 