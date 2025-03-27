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

output "web_server_public_ip" {
  description = "The public IP of the web server"
  value       = aws_eip.web.public_ip
}

output "web_server_id" {
  description = "The ID of the web server instance"
  value       = aws_instance.web.id
}

output "database_endpoint" {
  description = "The endpoint of the database instance"
  value       = aws_db_instance.main.endpoint
}

output "nat_gateway_public_ip" {
  description = "The public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "cloudwatch_alarm_arn" {
  description = "The ARN of the CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.web_cpu.arn
} 