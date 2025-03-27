output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.main.id
}

output "instance_id" {
  description = "The ID of the VM instance"
  value       = google_compute_instance.web.id
}

output "instance_public_ip" {
  description = "The public IP address of the web server"
  value       = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}

output "bucket_name" {
  description = "The name of the application data bucket"
  value       = google_storage_bucket.app_data.name
}

output "service_account_email" {
  description = "The email of the service account"
  value       = google_service_account.app_sa.email
}

# This shows the dependency graph relationships
output "instance_dependencies" {
  description = "Resources the VM instance depends on (explicitly and implicitly)"
  value = [
    "Explicit dependencies: google_compute_firewall.allow_http, google_compute_firewall.allow_ssh",
    "Implicit dependencies: google_compute_network.main, google_compute_subnetwork.main"
  ]
} 