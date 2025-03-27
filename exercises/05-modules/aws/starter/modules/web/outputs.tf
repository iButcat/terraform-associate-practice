output "security_group_id" {
  description = "The ID of the web security group"
  value       = aws_security_group.web.id
}

output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.web[*].public_ip
} 