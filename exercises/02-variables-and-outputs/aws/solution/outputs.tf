output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.main[*].id
}

output "subnet_cidr_blocks" {
  description = "CIDR blocks of the created subnets"
  value       = aws_subnet.main[*].cidr_block
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.instance.id
}

output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = aws_instance.app[*].id
}

output "instance_public_ips" {
  description = "Public IPs of the created EC2 instances"
  value       = aws_instance.app[*].public_ip
}

output "instance_private_ips" {
  description = "Private IPs of the created EC2 instances"
  value       = aws_instance.app[*].private_ip
}

# Formatted output using functions
output "resource_summary" {
  description = "Summary of created resources"
  value = format(
    "Created VPC %s with %d subnet(s) and %d instance(s) in %s environment",
    aws_vpc.main.id,
    length(aws_subnet.main),
    length(aws_instance.app),
    var.environment
  )
}

# Output with sensitive value
output "password_parameter_name" {
  description = "Name of the SSM parameter storing the database password"
  value       = aws_ssm_parameter.db_password.name
}

# Sensitive output
output "db_password" {
  description = "The database password (sensitive)"
  value       = var.db_password
  sensitive   = true
}

# Conditional output
output "environment_info" {
  description = "Environment information"
  value       = var.environment == "prod" ? "Production environment - handle with care" : "Non-production environment (${var.environment})"
}

# Output using for expression
output "subnet_details" {
  description = "Map of subnet IDs to CIDR blocks"
  value       = { for subnet in aws_subnet.main : subnet.id => subnet.cidr_block }
}

# Output using complex expression
output "availability_zone_mapping" {
  description = "Map of subnet IDs to availability zones"
  value       = { for subnet in aws_subnet.main : subnet.id => subnet.availability_zone }
}

# Output showing availability zone distribution
output "instance_az_distribution" {
  description = "Distribution of instances across availability zones"
  value = {
    for az in distinct([for instance in aws_instance.app : instance.availability_zone]) :
    az => length([for instance in aws_instance.app : instance.id if instance.availability_zone == az])
  }
} 