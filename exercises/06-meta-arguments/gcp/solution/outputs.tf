output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.main.id
}

output "secondary_network_id" {
  description = "The ID of the secondary VPC network (if created)"
  value       = var.enable_secondary_region ? google_compute_network.secondary[0].id : null
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
  description = "The names of the web instances mapped to their IDs"
  value = {
    for i, instance in google_compute_instance.web :
    var.instance_names[i] => instance.id
  }
}

output "web_external_ips" {
  description = "The external IPs of the web instances"
  value       = [for instance in google_compute_instance.web : instance.network_interface[0].access_config[0].nat_ip]
}

output "backend_instance_id" {
  description = "The ID of the backend instance"
  value       = google_compute_instance.backend.id
}

output "bucket_names" {
  description = "The names of the environment buckets"
  value = {
    for env, bucket in google_storage_bucket.environments :
    env => bucket.name
  }
}

output "logging_bucket_names" {
  description = "The names of the logging buckets"
  value = {
    for key, bucket in google_storage_bucket.logging :
    key => bucket.name
  }
}

output "firewall_ids" {
  description = "The IDs of the tier firewall rules"
  value = {
    for tier, fw in google_compute_firewall.tiers :
    tier => fw.id
  }
}

output "db_instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.main.name
}

output "db_connection_name" {
  description = "The connection name of the database instance"
  value       = google_sql_database_instance.main.connection_name
}

output "secondary_instance_ip" {
  description = "The external IP of the secondary region instance (if created)"
  value       = var.enable_secondary_region ? google_compute_instance.secondary[0].network_interface[0].access_config[0].nat_ip : null
} 