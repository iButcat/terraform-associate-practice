output "instance_ids" {
  description = "The IDs of the instances"
  value       = google_compute_instance.web[*].id
}

output "instance_names" {
  description = "The names of the instances"
  value       = google_compute_instance.web[*].name
}

output "instance_self_links" {
  description = "The URIs of the instances"
  value       = google_compute_instance.web[*].self_link
}

output "instance_external_ips" {
  description = "The external IPs of the instances"
  value       = [for i in google_compute_instance.web : i.network_interface[0].access_config[0].nat_ip]
} 