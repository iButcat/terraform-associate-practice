environment     = "prod"
instance_count  = 4
instance_type   = "e2-standard-2"
enable_public_ip = true

network_config = {
  network_name         = "terraform-prod-network"
  auto_create_subnets  = false
  subnet_name          = "terraform-prod-subnet"
  subnet_ip_cidr_range = "10.0.10.0/24"
  subnet_region        = "us-central1"
}

labels = {
  environment = "production"
  project     = "terraform-exercise"
  managed_by  = "terraform"
  team        = "devops"
  criticality = "high"
}

# Tuple of [image, machine_type, boot_disk_size]
instance_settings = ["debian-cloud/debian-11", "e2-standard-2", 20]

allowed_ports = [22, 80, 443, 8080]

additional_subnets = {
  "prod-subnet-1" = {
    cidr_range = "10.0.11.0/24"
    region     = "us-central1"
    private    = true
  },
  "prod-subnet-2" = {
    cidr_range = "10.0.12.0/24"
    region     = "us-central1"
    private    = true
  },
  "prod-public-subnet" = {
    cidr_range = "10.0.13.0/24"
    region     = "us-central1"
    private    = false
  }
} 