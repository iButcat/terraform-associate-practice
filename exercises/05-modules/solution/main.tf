provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = "10.0.0.0/16"
  environment        = "dev"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  tags = {
    Environment = "dev"
    Project     = "learning"
  }
}

module "web" {
  source = "./modules/ec2"
  
  environment    = "dev"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  instance_count = 2
  ami_id         = "ami-0c55b159cbfafe1f0"
  instance_type  = "t2.micro"
  
  tags = {
    Environment = "dev"
    Project     = "learning"
  }
}

module "db" {
  source = "./modules/rds"
  
  environment                = "dev"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.web.security_group_id]
  
  database_name = "example"
  username      = "admin"
  password      = "example-password"  # In production, use variables and secrets management
  
  tags = {
    Environment = "dev"
    Project     = "learning"
  }
} 