output "endpoint" {
  description = "The database endpoint"
  value       = aws_db_instance.db.endpoint
}

output "security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "db_instance_id" {
  description = "The ID of the database instance"
  value       = aws_db_instance.db.id
} 