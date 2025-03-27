resource "google_compute_network" "vpc_network" {
  name                    = "${var.environment}-${var.vpc_name}"
  auto_create_subnetworks = false
  
  project = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  count         = length(var.subnet_cidrs)
  name          = "${var.environment}-subnet-${count.index + 1}"
  ip_cidr_range = var.subnet_cidrs[count.index]
  region        = var.subnet_regions[count.index % length(var.subnet_regions)]
  network       = google_compute_network.vpc_network.self_link
  
  project = var.project_id
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
  }
  
  allow {
    protocol = "udp"
  }
  
  source_ranges = var.subnet_cidrs
  
  project = var.project_id
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh"
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  
  project = var.project_id
} 