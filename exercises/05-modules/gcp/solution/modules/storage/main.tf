resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "static" {
  name          = "${var.bucket_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  location      = var.bucket_location
  storage_class = var.storage_class
  
  uniform_bucket_level_access = true
  
  project = var.project_id
  
  labels = {
    environment = var.environment
  }
}

resource "google_storage_bucket_object" "welcome_page" {
  name    = "index.html"
  bucket  = google_storage_bucket.static.name
  content = <<-EOF
    <html>
      <head>
        <title>Hello from Terraform</title>
      </head>
      <body>
        <h1>Hello from Terraform Module (Storage)</h1>
        <p>This file is stored in a Google Cloud Storage bucket created by Terraform.</p>
      </body>
    </html>
  EOF
  
  content_type = "text/html"
} 