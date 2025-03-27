aws_region       = "us-east-1"
secondary_region = "us-west-2"
environment      = "development"
instance_count   = 2

developer_names = [
  "dev1",
  "dev2",
  "dev3"
]

bucket_names = [
  "data-bucket-1",
  "data-bucket-2",
  "data-bucket-3"
]

operator_roles = {
  "op1" = {
    role = "SysAdmin"
    team = "Infrastructure"
  },
  "op2" = {
    role = "DevOps"
    team = "Platform"
  }
}

vpc_config = {
  cidr_block           = "10.0.0.0/16"
  subnet_cidrs         = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_dns_hostnames = true
}

instance_type = "t2.micro"
ami_id        = "ami-0c55b159cbfafe1f0"

db_config = {
  identifier        = "example"
  engine           = "postgres"
  engine_version   = "13.7"
  instance_class   = "db.t3.micro"
  allocated_storage = 20
  db_name          = "example"
  username         = "admin"
  password         = "example-password"
}

common_tags = {
  Project     = "terraform-learning"
  Environment = "development"
  Terraform   = "true"
} 