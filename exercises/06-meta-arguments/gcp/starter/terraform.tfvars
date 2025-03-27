project_id     = "my-terraform-project-123"
primary_region = "us-central1"
environment    = "dev"
machine_type   = "e2-micro"
zones = [
  "us-central1-a",
  "us-central1-b",
  "us-central1-c"
]
subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]
instance_names = [
  "web-1",
  "web-2",
  "web-3"
] 