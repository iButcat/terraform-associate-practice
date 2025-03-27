output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = aws_subnet.public[*].id
}

output "web_instance_ids" {
  description = "The IDs of the web instances"
  value       = aws_instance.web[*].id
}

output "web_public_ips" {
  description = "The public IPs of the web instances"
  value       = aws_instance.web[*].public_ip
} 