project_id       = "terraform-exercise-project"
region          = "us-central1"
zone            = "us-central1-a"
instance_name   = "terraform-instance"
instance_type   = "e2-micro"
instance_count  = 2
enable_public_ip = true
environment     = "dev"

# Do not store this in version control in a real environment
# Use environment variables or a secrets manager instead
db_password     = "SecurePassword123!"

zones = [
  "us-central1-a",
  "us-central1-b",
  "us-central1-c"
]

labels = {
  environment = "development"
  project     = "terraform-exercise"
  managed_by  = "terraform"
  team        = "devops"
}

network_config = {
  network_name         = "terraform-network"
  auto_create_subnets  = false
  subnet_name          = "terraform-subnet"
  subnet_ip_cidr_range = "10.0.1.0/24"
  subnet_region        = "us-central1"
}

# Tuple of [image, machine_type, boot_disk_size]
instance_settings = ["debian-cloud/debian-11", "e2-micro", 10]

allowed_ports = [22, 80, 443]

additional_subnets = {
  "additional-subnet-1" = {
    cidr_range = "10.0.2.0/24"
    region     = "us-central1"
    private    = true
  },
  "additional-subnet-2" = {
    cidr_range = "10.0.3.0/24"
    region     = "us-central1"
    private    = false
  }
} 