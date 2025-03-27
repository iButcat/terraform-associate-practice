# Basic output types
output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

# List output
output "instance_names" {
  description = "Names of all VM instances"
  value       = google_compute_instance.vm_instances[*].name
}

# Map output using for expression
output "instance_ips" {
  description = "Map of instance names to their public IPs"
  value       = {
    for instance in google_compute_instance.vm_instances :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
  }
}

# Structured output using zipmap
output "instance_details" {
  description = "Map of instance names to their details"
  value = zipmap(
    google_compute_instance.vm_instances[*].name,
    [
      for instance in google_compute_instance.vm_instances : {
        ip       = instance.network_interface[0].access_config[0].nat_ip
        zone     = instance.zone
        machine_type = instance.machine_type
      }
    ]
  )
}

# Output with formatting using string interpolation
output "summary" {
  description = "Summary of the deployment"
  value       = "Deployed ${var.instance_count} VM instances in ${var.environment} environment using ${var.instance_type} machine type in ${var.region} region."
}

# Additional subnet output
output "additional_subnets" {
  description = "Additional subnets that were created"
  value       = {
    for key, subnet in google_compute_subnetwork.additional_subnets :
    key => {
      id           = subnet.id
      ip_cidr_range = subnet.ip_cidr_range
      region       = subnet.region
    }
  }
}

# Conditional output
output "storage_bucket_url" {
  description = "URL of the storage bucket (if created)"
  value       = var.environment == "prod" ? (length(google_storage_bucket.storage) > 0 ? google_storage_bucket.storage[0].url : null) : "No storage bucket created in non-production environment"
}

# Sensitive output
output "database_connection_string" {
  description = "Database connection string (sensitive)"
  value       = "postgresql://terraform-user:${var.db_password}@${google_sql_database_instance.db_instance.connection_name}/example-database"
  sensitive   = true
}

# Output using join
output "instance_ids" {
  description = "Comma separated list of all instance IDs"
  value       = join(", ", google_compute_instance.vm_instances[*].id)
}

# Output with dynamic content based on variable
output "environment_message" {
  description = "Message based on environment"
  value = var.environment == "prod" ? "This is a PRODUCTION environment. Use with caution!" : (
    var.environment == "test" ? "This is a TEST environment." : "This is a DEVELOPMENT environment."
  )
} 