aws_region = "us-east-1"
vpc_cidr    = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
db_subnet_cidrs      = ["10.0.5.0/24", "10.0.6.0/24"]

availability_zones = ["us-east-1a", "us-east-1b"]
environment        = "dev"
instance_type      = "t2.micro"
db_instance_class  = "db.t2.micro"

db_name     = "appdb"
db_username = "admin"
db_password = "password123" # In a real project, use a secrets manager or environment variables 