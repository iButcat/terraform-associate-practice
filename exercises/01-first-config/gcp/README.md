# Exercise 1: Your First Terraform Configuration (GCP)

## Objective

Learn how to create a basic Terraform configuration to deploy Google Cloud infrastructure. This exercise will help you understand the core Terraform workflow with GCP resources.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- Google Cloud account with a project 
- Google Cloud SDK installed OR service account key available

## GCP Authentication

You have two options for GCP authentication:

1. **Google Cloud SDK Configuration**:
   - Install and configure the Google Cloud SDK
   - Run `gcloud auth application-default login`
   - Terraform will automatically use these credentials

2. **Service Account Key**:
   - Create a service account in GCP with appropriate permissions
   - Download the JSON key file
   - Set the environment variable:
     ```bash
     export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your-key.json"
     ```
   - Or specify directly in the provider (not recommended for production):
     ```hcl
     provider "google" {
       project     = "your-project-id"
       region      = "us-central1"
       credentials = file("/path/to/your-key.json")
     }
     ```

## Instructions

### Step 1: Create the Configuration Files

Create a new directory for this exercise and navigate to it:

```bash
mkdir -p terraform-exercises/01-first-config
cd terraform-exercises/01-first-config
```

Create the following files:

1. `main.tf` - Main configuration file

```hcl
# Configure the Google Cloud Provider
provider "google" {
  project = "your-project-id"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Create a VPC
resource "google_compute_network" "main" {
  name                    = "main-vpc"
  auto_create_subnetworks = false
  description             = "Main VPC network created by Terraform"
}

# Create a subnet within the VPC
resource "google_compute_subnetwork" "main" {
  name          = "main-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
}

# Create a firewall rule
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  description   = "Allow SSH from anywhere"
}
```

2. `outputs.tf` - Define outputs

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.main.id
}

output "firewall_rule_id" {
  description = "The ID of the firewall rule"
  value       = google_compute_firewall.allow_ssh.id
}
```

3. `versions.tf` - Define provider versions

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

### Step 2: Initialize the Working Directory

Run the following command to initialize your working directory:

```bash
terraform init
```

You should see output indicating that Terraform has been successfully initialized and the Google provider has been installed.

### Step 3: Format and Validate the Configuration

Format your configuration files for consistency:

```bash
terraform fmt
```

Validate your configuration syntax:

```bash
terraform validate
```

You should see a message that the configuration is valid.

### Step 4: Create an Execution Plan

Generate an execution plan:

```bash
terraform plan
```

Review the execution plan to understand what Terraform will do. You should see that Terraform plans to create 3 resources:
- 1 VPC network
- 1 subnet
- 1 firewall rule

### Step 5: Apply the Configuration

Apply the configuration to create the resources:

```bash
terraform apply
```

When prompted, type `yes` to confirm. Terraform will proceed to create the resources in your Google Cloud project.

After the apply is complete, you should see the output values for the VPC ID, subnet ID, and firewall rule ID.

### Step 6: Verify the Created Resources

1. Log in to the Google Cloud Console
2. Navigate to the VPC Network service
3. Confirm that the VPC, subnet, and firewall rule have been created with the specified configuration

### Step 7: Examine the State File

Take a look at the state file that Terraform created:

```bash
terraform state list
```

This command shows all the resources in your state file.

To see details of a specific resource:

```bash
terraform state show google_compute_network.main
```

### Step 8: Destroy the Resources

When you're finished, destroy the resources to avoid any ongoing charges:

```bash
terraform destroy
```

When prompted, type `yes` to confirm.

## Additional Challenges

1. Modify your configuration to add a second subnet in a different region
2. Add a Cloud Router and NAT Gateway to allow instances without external IPs to access the internet
3. Create more specific firewall rules for different types of traffic
4. Use variables to parameterize your configuration (e.g., for project ID, region, CIDR blocks)

## Solution

The solution for this exercise is provided in the [solution](./solution) directory.

## Key Learnings

- How to configure the Google Cloud provider
- How to create basic GCP networking resources
- How GCP resources refer to each other
- The core Terraform workflow with GCP
- How to view and interpret the state file 