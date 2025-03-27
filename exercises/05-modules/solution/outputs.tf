output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "web_instance_ids" {
  description = "List of web server instance IDs"
  value       = module.web.instance_ids
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = module.db.endpoint
} 