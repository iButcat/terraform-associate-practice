output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.web[*].id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
} 