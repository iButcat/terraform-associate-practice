output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "instance_id" {
  description = "The ID of the VM instance"
  value       = google_compute_instance.web.id
}

output "public_ip" {
  description = "The public IP address of the web server"
  value       = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}

output "firewall_id" {
  description = "The ID of the firewall rule"
  value       = google_compute_firewall.allow_http_ssh.id
} 