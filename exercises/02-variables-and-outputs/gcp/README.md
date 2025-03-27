# Exercise 2: Variables and Outputs in Terraform (GCP)

## Objective

Learn how to use variables and outputs in Terraform with Google Cloud Platform resources to make configurations more flexible, maintainable, and reusable.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- Completion of Exercise 1: Your First Terraform Configuration (GCP)
- Google Cloud account with a project
- Google Cloud SDK installed OR service account key available

## Instructions

### Step 1: Create the Configuration Files

Create a new directory for this exercise and set up the following files:

```bash
mkdir -p terraform-exercises/02-variables-and-outputs
cd terraform-exercises/02-variables-and-outputs
touch main.tf variables.tf outputs.tf versions.tf terraform.tfvars
```

### Step 2: Define Variables

Edit the `variables.tf` file to define variables for your configuration:

```hcl
# Basic variable types
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for resources that require a zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Base name for the VM instances"
  type        = string
}

variable "instance_type" {
  description = "Machine type for VM instances"
  type        = string
  default     = "e2-micro"
}

# Number variable
variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5."
  }
}

# Boolean variable
variable "enable_public_ip" {
  description = "Whether to assign a public IP to the instances"
  type        = bool
  default     = true
}

# List variable
variable "zones" {
  description = "List of zones to use for resources"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

# Map variable
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    environment = "development"
    project     = "terraform-exercise"
  }
}

# Variable with validation
variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, prod."
  }
}

# Object variable
variable "network_config" {
  description = "Configuration for the VPC network"
  type = object({
    network_name         = string
    auto_create_subnets  = bool
    subnet_name          = string
    subnet_ip_cidr_range = string
    subnet_region        = string
  })
  default = {
    network_name         = "terraform-network"
    auto_create_subnets  = false
    subnet_name          = "terraform-subnet"
    subnet_ip_cidr_range = "10.0.1.0/24"
    subnet_region        = "us-central1"
  }
}

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### Step 3: Create the terraform.tfvars File

Edit the `terraform.tfvars` file to set values for your variables:

```hcl
project_id     = "your-project-id"  # Replace with your actual project ID
region         = "us-central1"
zone           = "us-central1-a"
instance_name  = "terraform-exercise-instance"
instance_type  = "e2-micro"
instance_count = 1
enable_public_ip = true
environment    = "dev"
db_password    = "changeme123!"  # In real scenarios, never commit passwords to version control

network_config = {
  network_name         = "terraform-network"
  auto_create_subnets  = false
  subnet_name          = "terraform-subnet"
  subnet_ip_cidr_range = "10.0.1.0/24"
  subnet_region        = "us-central1"
}

labels = {
  environment = "development"
  project     = "terraform-exercise"
  owner       = "your-name"
}
```

### Step 4: Define Local Values

Edit the `main.tf` file to define local values:

```hcl
# Define local values
locals {
  # Combine common labels with environment-specific labels
  common_labels = merge(
    var.labels,
    {
      environment = var.environment
    }
  )
  
  # Create a formatted instance name prefix
  instance_name_prefix = "${var.environment}-${var.instance_name}"
  
  # Create zone to instance count mappings
  instance_zones = slice(var.zones, 0, var.instance_count)
  
  # Create SSH firewall rule settings
  ssh_firewall_rule = {
    name        = "${var.environment}-allow-ssh"
    protocol    = "tcp"
    ports       = ["22"]
    source_ranges = ["0.0.0.0/0"]
    description = "Allow SSH access from anywhere"
  }
  
  # Format the metadata startup script content
  startup_script = <<-EOT
    #!/bin/bash
    echo "Hello from ${var.environment} environment!"
    echo "Instance deployed by Terraform"
  EOT
}
```

### Step 5: Define Resources Using Variables and Locals

Continue editing the `main.tf` file to use variables and locals in your resource definitions:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.network_config.network_name
  auto_create_subnetworks = var.network_config.auto_create_subnets
  description             = "Network created for ${var.environment} environment"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.network_config.subnet_name
  ip_cidr_range = var.network_config.subnet_ip_cidr_range
  region        = var.network_config.subnet_region
  network       = google_compute_network.vpc.id
}

# Firewall Rules
resource "google_compute_firewall" "ssh" {
  name        = local.ssh_firewall_rule.name
  network     = google_compute_network.vpc.name
  description = local.ssh_firewall_rule.description
  
  allow {
    protocol = local.ssh_firewall_rule.protocol
    ports    = local.ssh_firewall_rule.ports
  }
  
  source_ranges = local.ssh_firewall_rule.source_ranges
  
  labels = local.common_labels
}

# Create instances
resource "google_compute_instance" "vm_instances" {
  count        = var.instance_count
  name         = "${local.instance_name_prefix}-${count.index + 1}"
  machine_type = var.instance_type
  zone         = element(local.instance_zones, count.index)
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  
  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    
    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        // Ephemeral IP
      }
    }
  }
  
  metadata = {
    environment = var.environment
    terraform   = "true"
  }
  
  metadata_startup_script = local.startup_script
  
  labels = local.common_labels
}

# Store sensitive data in Secret Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.environment}-db-password"
  
  labels = local.common_labels
  
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}
```

### Step 6: Define Outputs

Edit the `outputs.tf` file to define outputs that will be displayed after applying the configuration:

```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_gateway" {
  description = "Gateway address of the subnet"
  value       = google_compute_subnetwork.subnet.gateway_address
}

output "instance_ids" {
  description = "IDs of the created VM instances"
  value       = google_compute_instance.vm_instances[*].id
}

output "instance_names" {
  description = "Names of the created VM instances"
  value       = google_compute_instance.vm_instances[*].name
}

output "instance_internal_ips" {
  description = "Internal IPs of the created VM instances"
  value = [
    for instance in google_compute_instance.vm_instances : 
    instance.network_interface[0].network_ip
  ]
}

output "instance_external_ips" {
  description = "External IPs of the created VM instances (if enabled)"
  value = var.enable_public_ip ? [
    for instance in google_compute_instance.vm_instances : 
    instance.network_interface[0].access_config[0].nat_ip
  ] : ["No external IPs assigned"]
}

# Formatted output using functions
output "resource_summary" {
  description = "Summary of created resources"
  value = format(
    "Created VPC %s with subnet %s and %d VM instance(s) in %s environment",
    google_compute_network.vpc.name,
    google_compute_subnetwork.subnet.name,
    var.instance_count,
    var.environment
  )
}

# Output with sensitive value reference
output "secret_name" {
  description = "Name of the secret in Secret Manager"
  value       = google_secret_manager_secret.db_password.name
}

# Sensitive output
output "db_password" {
  description = "The database password (sensitive)"
  value       = var.db_password
  sensitive   = true
}

# Conditional output
output "environment_info" {
  description = "Environment information"
  value       = var.environment == "prod" ? "Production environment - handle with care" : "Non-production environment (${var.environment})"
}

# Output using for expression
output "instance_details" {
  description = "Map of instance names to their zones"
  value       = { for vm in google_compute_instance.vm_instances : vm.name => vm.zone }
}
```

### Step 7: Set Up Versions Constraints

Edit the `versions.tf` file to define provider and Terraform versions:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  
  required_version = ">= 1.0.0"
}
```

### Step 8: Initialize and Apply the Configuration

```bash
terraform init
terraform plan
terraform apply
```

### Step 9: Experiment with Variable Values

Try changing variable values to see how it affects your configuration:

1. Edit the `terraform.tfvars` file to change values:
   ```hcl
   instance_count = 2
   environment    = "test"
   ```

2. Apply the changes:
   ```bash
   terraform apply
   ```

3. Observe how the changes in variables affect resources and outputs.

### Step 10: Use Variable Overrides

Try overriding variables using command-line flags:

```bash
terraform apply -var="instance_count=3" -var="environment=prod"
```

### Step 11: Use a Different Variable File

Create a production-specific variable file:

```bash
touch prod.tfvars
```

Edit `prod.tfvars`:
```hcl
environment     = "prod"
instance_count  = 2
instance_type   = "e2-medium"
enable_public_ip = false
labels = {
  environment = "production"
  project     = "terraform-exercise"
  owner       = "your-name"
  cost_center = "123456"
}
```

Apply with the production variable file:
```bash
terraform apply -var-file="prod.tfvars"
```

### Step 12: Clean Up

Destroy the resources to avoid charges:

```bash
terraform destroy
```

## Additional Challenges

1. Add a tuple variable type with mixed data types
2. Implement a regex validation for a variable that must match a specific pattern
3. Create a more complex network topology with multiple subnets in different regions
4. Use the `templatefile` function to generate a more sophisticated startup script
5. Implement dynamic blocks for firewall rules based on variable inputs

## Solution

See the [solution directory](./solution) for a complete working example.

## Key Learnings

- Variables make Terraform configurations flexible and reusable
- Different variable types serve different purposes
- Variables can have default values and validation rules
- Local values help reduce repetition and compute derived values
- Variables can be provided through multiple methods with a specific precedence
- Outputs extract useful information about created resources
- Functions and expressions can manipulate variable values and format outputs
- Using variables effectively makes configurations more maintainable and adaptable 