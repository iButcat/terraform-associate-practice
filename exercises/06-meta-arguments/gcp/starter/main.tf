provider "google" {
  project = var.project_id
  region  = var.primary_region
}

# VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.environment}-network"
  auto_create_subnetworks = false
}

# Subnet
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
  }
} 