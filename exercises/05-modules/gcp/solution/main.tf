provider "google" {
  project = var.project_id
  region  = var.region
}

module "vpc" {
  source = "./modules/vpc"
  
  project_id     = var.project_id
  environment    = var.environment
  vpc_name       = "main"
  subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_regions = [var.region, var.secondary_region]
  
  tags = {
    Project = "terraform-modules-exercise"
  }
}

module "compute" {
  source = "./modules/compute"
  
  project_id        = var.project_id
  environment       = var.environment
  instance_count    = 2
  machine_type      = "e2-micro"
  vpc_self_link     = module.vpc.vpc_self_link
  subnet_self_links = module.vpc.subnet_self_links
  zones             = var.zones
  
  tags = {
    Project = "terraform-modules-exercise"
  }
}

module "storage" {
  source = "./modules/storage"
  
  project_id      = var.project_id
  environment     = var.environment
  bucket_name     = "tf-module-demo"
  bucket_location = "US"
  
  tags = {
    Project = "terraform-modules-exercise"
  }
} 