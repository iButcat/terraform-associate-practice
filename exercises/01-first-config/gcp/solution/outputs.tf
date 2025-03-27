output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.main.id
}

output "main_subnet_id" {
  description = "The ID of the main subnet"
  value       = google_compute_subnetwork.main.id
}

output "secondary_subnet_id" {
  description = "The ID of the secondary subnet"
  value       = google_compute_subnetwork.secondary.id
}

output "ssh_firewall_id" {
  description = "The ID of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.id
}

output "internal_firewall_id" {
  description = "The ID of the internal firewall rule"
  value       = google_compute_firewall.allow_internal.id
}

output "router_id" {
  description = "The ID of the Cloud Router"
  value       = google_compute_router.router.id
}

output "nat_id" {
  description = "The ID of the NAT Gateway"
  value       = google_compute_router_nat.nat.id
} 