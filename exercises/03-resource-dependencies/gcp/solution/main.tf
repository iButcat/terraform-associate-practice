provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a VPC network (implicit dependency example)
resource "google_compute_network" "main" {
  name                    = "${var.environment}-network"
  auto_create_subnetworks = false
}

# Create a subnet (depends implicitly on the VPC)
resource "google_compute_subnetwork" "main" {
  name          = "${var.environment}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id  # Implicit dependency
}

# Create a firewall rule (depends implicitly on the VPC)
resource "google_compute_firewall" "allow_http" {
  name    = "${var.environment}-allow-http"
  network = google_compute_network.main.name  # Implicit dependency

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# Create a firewall rule for SSH (depends implicitly on the VPC)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh"
  network = google_compute_network.main.name  # Implicit dependency

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create a VM instance (depends on the subnet and firewall rules)
resource "google_compute_instance" "web" {
  name         = "${var.environment}-web-server"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.main.name     # Implicit dependency
    subnetwork = google_compute_subnetwork.main.name  # Implicit dependency
    
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
    echo "<h1>Hello from Terraform on GCP</h1>" > /var/www/html/index.html
  EOF

  tags = ["web"]

  # Explicit dependency examples
  depends_on = [
    google_compute_firewall.allow_http,
    google_compute_firewall.allow_ssh
  ]
}

# Create a Cloud Storage bucket to store application data
resource "google_storage_bucket" "app_data" {
  name          = "app-data-${var.environment}-${random_id.bucket_suffix.hex}"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
}

# Generate random string for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create a service account
resource "google_service_account" "app_sa" {
  account_id   = "${var.environment}-app-sa"
  display_name = "Application Service Account"
}

# IAM binding for the service account
resource "google_storage_bucket_iam_binding" "app_sa_storage_binding" {
  bucket = google_storage_bucket.app_data.name
  role   = "roles/storage.objectAdmin"
  
  members = [
    "serviceAccount:${google_service_account.app_sa.email}"
  ]
  
  # Explicit dependency on both resources
  depends_on = [
    google_service_account.app_sa,
    google_storage_bucket.app_data
  ]
} 