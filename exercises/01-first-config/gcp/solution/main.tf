# Configure the Google Cloud Provider
provider "google" {
  project = "your-project-id"  # Replace with your actual project ID
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Create a VPC
resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  description             = "Main VPC network created by Terraform"
}

# Create a primary subnet within the VPC
resource "google_compute_subnetwork" "main" {
  name          = "main-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
}

# Create a secondary subnet within the VPC
resource "google_compute_subnetwork" "secondary" {
  name          = "secondary-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-west1"
  network       = google_compute_network.main.id
}

# Create a firewall rule for SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  description   = "Allow SSH from anywhere"
}

# Create a firewall rule for internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/16"]
  description   = "Allow internal communication between resources"
}

# Create a Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "main-router"
  region  = "us-central1"
  network = google_compute_network.main.id
}

# Create a NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "main-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
} 