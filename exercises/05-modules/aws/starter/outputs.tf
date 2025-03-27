output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "web_instance_ids" {
  description = "The IDs of the web instances"
  value       = module.web.instance_ids
}

output "web_public_ips" {
  description = "The public IPs of the web instances"
  value       = module.web.public_ips
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value       = module.db.endpoint
} 