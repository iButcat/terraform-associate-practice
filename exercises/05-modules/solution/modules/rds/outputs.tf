output "endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.db.id
} 