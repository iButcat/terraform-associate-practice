output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc_network.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc_network.name
}

output "vpc_self_link" {
  description = "The URI of the VPC"
  value       = google_compute_network.vpc_network.self_link
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = google_compute_subnetwork.subnets[*].id
}

output "subnet_self_links" {
  description = "The URIs of the subnets"
  value       = google_compute_subnetwork.subnets[*].self_link
}

output "subnet_regions" {
  description = "The regions of the subnets"
  value       = google_compute_subnetwork.subnets[*].region
} 