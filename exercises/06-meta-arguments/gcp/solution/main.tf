provider "google" {
  project = var.project_id
  region  = var.primary_region
}

# Define a secondary provider
provider "google" {
  alias   = "secondary"
  project = var.project_id
  region  = var.secondary_region
}

# VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.environment}-network"
  auto_create_subnetworks = false

  lifecycle {
    create_before_destroy = true
  }
}

# Subnet using count
resource "google_compute_subnetwork" "main" {
  count         = length(var.subnet_cidrs)
  name          = "${var.environment}-subnet-${count.index}"
  ip_cidr_range = var.subnet_cidrs[count.index]
  region        = var.primary_region
  network       = google_compute_network.main.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "${var.environment}-allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Compute Instances using count
resource "google_compute_instance" "web" {
  count        = length(var.instance_names)
  name         = var.instance_names[count.index]
  machine_type = var.machine_type
  zone         = var.zones[count.index % length(var.zones)]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main[count.index % length(google_compute_subnetwork.main)].name
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello from Terraform - Instance ${var.instance_names[count.index]}</h1>" > /var/www/html/index.html
  EOF

  tags = ["web"]

  labels = {
    environment = var.environment
    updated_at  = timestamp()
  }

  lifecycle {
    ignore_changes = [
      labels["updated_at"]
    ]
  }
}

# Generate a random string for bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Cloud Storage Buckets using for_each with a map
resource "google_storage_bucket" "environments" {
  for_each = var.environments

  name     = "terraform-meta-args-${var.project_id}-${each.key}-${random_string.bucket_suffix.result}"
  location = each.value.location
  
  uniform_bucket_level_access = true

  labels = {
    environment   = each.key
    instance_type = each.value.instance_type
    instance_count = each.value.instance_count
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

# Cloud Storage Buckets using for_each with a set
resource "google_storage_bucket" "logging" {
  for_each = toset(["access", "error", "debug"])

  name     = "terraform-meta-args-${var.project_id}-logs-${each.key}-${random_string.bucket_suffix.result}"
  location = var.primary_region
  
  uniform_bucket_level_access = true

  labels = {
    environment = var.environment
    log_type    = each.key
  }
}

# Cloud SQL instance with lifecycle rules
resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-db-${random_string.bucket_suffix.result}"
  database_version = "MYSQL_8_0"
  region           = var.primary_region
  
  settings {
    tier = var.db_machine_type
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }
  }
  
  # This needs to be false for destroy operations
  deletion_protection = true
  
  depends_on = [
    google_compute_network.main
  ]
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "users" {
  name     = var.db_username
  instance = google_sql_database_instance.main.name
  password = var.db_password
  
  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

# Firewall rules using for_each with a set
resource "google_compute_firewall" "tiers" {
  for_each = toset(["web", "app", "db"])
  
  name    = "${var.environment}-${each.key}-firewall"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = each.key == "web" ? ["80", "443"] : (
               each.key == "app" ? ["8080", "8443"] : ["3306"]
              )
  }
  
  source_ranges = each.key == "web" ? ["0.0.0.0/0"] : ["10.0.0.0/8"]
  target_tags   = [each.key]
}

# Explicit dependencies with depends_on
resource "google_compute_instance" "backend" {
  name         = "${var.environment}-backend"
  machine_type = var.machine_type
  zone         = var.zones[0]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main[0].name
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apache2
    systemctl start apache2
    systemctl enable apache2
    echo "<h1>Hello from Backend Server</h1>" > /var/www/html/index.html
  EOF

  tags = ["app"]

  labels = {
    environment = var.environment
  }

  # Explicit dependencies
  depends_on = [
    google_compute_subnetwork.main,
    google_sql_database_instance.main  # Ensure database is created first
  ]
}

# Using a secondary provider for multi-region resources
# Only create if enabled
resource "google_compute_network" "secondary" {
  count       = var.enable_secondary_region ? 1 : 0
  provider    = google.secondary
  name        = "${var.environment}-network-secondary"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "secondary" {
  count         = var.enable_secondary_region ? 1 : 0
  provider      = google.secondary
  name          = "${var.environment}-subnet-secondary"
  ip_cidr_range = "172.16.0.0/20"
  region        = var.secondary_region
  network       = google_compute_network.secondary[0].id
}

resource "google_compute_instance" "secondary" {
  count        = var.enable_secondary_region ? 1 : 0
  provider     = google.secondary
  name         = "${var.environment}-secondary-instance"
  machine_type = var.machine_type
  zone         = "${var.secondary_region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.secondary[0].name
    subnetwork = google_compute_subnetwork.secondary[0].name
    access_config {
      // Ephemeral IP
    }
  }

  tags = ["web"]

  labels = {
    environment = var.environment
  }
} 