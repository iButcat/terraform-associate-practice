output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.main[*].id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.instance.id
}

# Formatted output using functions
output "resource_summary" {
  description = "Summary of created resources"
  value = format(
    "Created VPC %s with %d subnet(s) in %s environment",
    aws_vpc.main.id,
    var.instance_count,
    var.environment
  )
}

# Output with sensitive value
output "password_parameter_name" {
  description = "Name of the SSM parameter storing the database password"
  value       = aws_ssm_parameter.db_password.name
}

# Conditional output
output "additional_info" {
  description = "Additional environment information"
  value       = var.environment == "prod" ? "Production environment - handle with care" : "Non-production environment"
}

# Using local values in outputs
output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}

# Conditional output based on existence of resources
output "elastic_ips" {
  description = "Elastic IPs if created"
  value       = var.enable_public_ip ? aws_eip.instance[*].public_ip : "No public IPs allocated"
}

# JSON formatted output
output "vpc_config_json" {
  description = "VPC configuration in JSON format"
  value       = jsonencode(var.vpc_config)
}

# Output combining multiple values
output "environment_summary" {
  description = "Environment summary information"
  value = {
    name            = var.environment
    is_production   = local.is_production
    instance_count  = var.instance_count
    vpc_id          = aws_vpc.main.id
    subnet_count    = length(local.subnet_ids)
    allowed_ports   = [for port in var.allowed_ports : port.port]
  }
} 