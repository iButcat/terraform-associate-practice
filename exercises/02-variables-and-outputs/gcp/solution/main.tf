provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_config.network_name
  auto_create_subnetworks = var.network_config.auto_create_subnets
}

# Create a subnet in the VPC
resource "google_compute_subnetwork" "subnet" {
  name          = var.network_config.subnet_name
  ip_cidr_range = var.network_config.subnet_ip_cidr_range
  region        = var.network_config.subnet_region
  network       = google_compute_network.vpc_network.id
}

# Additional subnets using for_each with a map
resource "google_compute_subnetwork" "additional_subnets" {
  for_each      = var.additional_subnets
  name          = each.key
  ip_cidr_range = each.value.cidr_range
  region        = each.value.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = each.value.private
}

# Create a firewall rule for SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Create firewall rules for allowed ports using dynamic blocks
resource "google_compute_firewall" "allow_custom_ports" {
  name    = "allow-custom-ports"
  network = google_compute_network.vpc_network.name

  dynamic "allow" {
    for_each = var.allowed_ports
    content {
      protocol = "tcp"
      ports    = [allow.value]
    }
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# Create VM instances with count
resource "google_compute_instance" "vm_instances" {
  count        = var.instance_count
  name         = "${var.instance_name}-${count.index + 1}"
  machine_type = var.instance_type
  zone         = element(var.zones, count.index % length(var.zones))

  boot_disk {
    initialize_params {
      image = var.instance_settings[0]
      size  = var.instance_settings[2]
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
      # Ephemeral IP - leaving this block empty assigns an ephemeral public IP
      nat_ip = var.enable_public_ip ? null : ""
    }
  }

  tags = ["ssh-enabled", "web"]

  labels = merge(var.labels, {
    instance_number = count.index + 1
    environment     = var.environment
  })

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "This is Terraform Exercise server ${count.index + 1} in ${var.environment} environment" > /var/www/html/index.html
  SCRIPT

  # Conditional creation of additional resources 
  provisioner "local-exec" {
    command = "echo Instance ${self.name} with IP ${self.network_interface[0].access_config[0].nat_ip} created on $(date) >> instance_info.log"
  }
}

# Create Cloud Storage bucket with conditional creation
resource "google_storage_bucket" "storage" {
  # Only create this bucket in production
  count         = var.environment == "prod" ? 1 : 0
  name          = "terraform-exercise-${var.project_id}-${var.environment}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = var.labels
}

# For demo purposes, we're creating a basic cloud SQL instance
# In a real environment, you would secure this properly
resource "google_sql_database_instance" "db_instance" {
  name             = "terraform-exercise-db-${var.environment}"
  database_version = "POSTGRES_13"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"
    
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"  # Overly permissive for demo only
        name  = "all"
      }
    }
  }
  
  deletion_protection = false  # For exercise purposes only
}

resource "google_sql_database" "database" {
  name     = "example-database"
  instance = google_sql_database_instance.db_instance.name
}

resource "google_sql_user" "users" {
  name     = "terraform-user"
  instance = google_sql_database_instance.db_instance.name
  password = var.db_password
} 