output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.main.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = google_compute_subnetwork.main[*].id
}

output "web_instance_ids" {
  description = "The IDs of the web instances"
  value       = google_compute_instance.web[*].id
}

output "web_instance_names" {
  description = "The names of the web instances"
  value       = google_compute_instance.web[*].name
}

output "web_external_ips" {
  description = "The external IPs of the web instances"
  value       = [for instance in google_compute_instance.web : instance.network_interface[0].access_config[0].nat_ip]
} 