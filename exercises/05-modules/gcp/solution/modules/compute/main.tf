resource "google_compute_firewall" "allow_http" {
  name    = "${var.environment}-allow-http"
  network = var.vpc_self_link
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
  
  project = var.project_id
}

resource "google_compute_instance" "web" {
  count        = var.instance_count
  name         = "${var.environment}-web-instance-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zones[count.index % length(var.zones)]
  
  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  
  network_interface {
    network    = var.vpc_self_link
    subnetwork = var.subnet_self_links[count.index % length(var.subnet_self_links)]
    
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
    echo "<h1>Hello from Terraform Module (Instance ${count.index + 1})</h1>" > /var/www/html/index.html
  EOF
  
  tags = ["web"]
  
  project = var.project_id
  
  labels = {
    environment = var.environment
  }
} 