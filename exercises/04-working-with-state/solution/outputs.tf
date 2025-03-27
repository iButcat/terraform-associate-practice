output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

output "web_server_id" {
  description = "The ID of the web server instance"
  value       = aws_instance.web.id
}

output "database_endpoint" {
  description = "The endpoint of the database instance"
  value       = aws_db_instance.main.endpoint
}

output "state_bucket_name" {
  description = "The name of the S3 bucket used for state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_lock_table_name" {
  description = "The name of the DynamoDB table used for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
} 