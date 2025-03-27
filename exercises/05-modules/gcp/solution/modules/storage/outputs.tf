output "bucket_name" {
  description = "The name of the bucket"
  value       = google_storage_bucket.static.name
}

output "bucket_url" {
  description = "The URL of the bucket"
  value       = google_storage_bucket.static.url
}

output "bucket_self_link" {
  description = "The URI of the bucket"
  value       = google_storage_bucket.static.self_link
} 