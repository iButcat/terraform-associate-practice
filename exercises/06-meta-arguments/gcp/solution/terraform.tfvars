project_id     = "my-terraform-project-123"
primary_region = "us-central1"
secondary_region = "us-west1"
environment    = "dev"
machine_type   = "e2-micro"
db_machine_type = "db-f1-micro"
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

environments = {
  dev = {
    location       = "US-CENTRAL1"
    instance_type  = "e2-micro"
    instance_count = 1
  },
  staging = {
    location       = "US-EAST1"
    instance_type  = "e2-small"
    instance_count = 2
  },
  prod = {
    location       = "US-WEST1"
    instance_type  = "e2-medium"
    instance_count = 3
  }
}

enable_secondary_region = true

db_name     = "mydb"
db_username = "admin"
# In a real environment, never store passwords in plain text
# Use environment variables, Secret Manager, or KMS
db_password = "ChangeMe123!" 