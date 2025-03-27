output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "main_subnet_id" {
  description = "ID of the main subnet"
  value       = aws_subnet.main.id
}

output "secondary_subnet_id" {
  description = "ID of the secondary subnet"
  value       = aws_subnet.secondary.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "route_table_id" {
  description = "ID of the Route Table"
  value       = aws_route_table.main.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.allow_ssh.id
}

output "region" {
  description = "AWS region used for resources"
  value       = var.aws_region
}

output "environment" {
  description = "Environment tag used for resources"
  value       = var.environment
} 