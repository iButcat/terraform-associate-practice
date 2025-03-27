environment     = "prod"
instance_count  = 3
instance_type   = "t3.small"
enable_public_ip = false

vpc_config = {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  subnet_cidrs         = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

tags = {
  Environment = "Production"
  Project     = "Terraform-Exercise"
  Owner       = "Your-Name"
  CostCenter  = "123456"
  ManagedBy   = "Terraform"
}

instance_settings = ["ami-0c55b159cbfafe1f0", "t3.small", true]

allowed_ingress_ports = [22, 443] 