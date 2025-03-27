output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_self_link" {
  description = "The self link of the VPC"
  value       = module.vpc.vpc_self_link
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = module.vpc.subnet_ids
}

output "subnet_self_links" {
  description = "The self links of the subnets"
  value       = module.vpc.subnet_self_links
}

output "instance_ids" {
  description = "The IDs of the instances"
  value       = module.compute.instance_ids
}

output "instance_external_ips" {
  description = "The external IPs of the instances"
  value       = module.compute.instance_external_ips
}

output "bucket_name" {
  description = "The name of the storage bucket"
  value       = module.storage.bucket_name
}

output "bucket_url" {
  description = "The URL of the storage bucket"
  value       = module.storage.bucket_url
} 