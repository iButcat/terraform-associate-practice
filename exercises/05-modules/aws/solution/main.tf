provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr          = var.vpc_cidr
  environment       = var.environment
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  tags = {
    Project = "terraform-modules-exercise"
  }
}

module "web" {
  source = "./modules/web"
  
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  instance_count = 2
  
  tags = {
    Project = "terraform-modules-exercise"
  }
}

module "db" {
  source = "./modules/db"
  
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.web.security_group_id]
  database_name             = "appdb"
  username                  = "admin"
  password                  = var.db_password
  
  tags = {
    Project = "terraform-modules-exercise"
  }
} 