# Exercise 6: Terraform Resource Meta-Arguments (GCP)

## Overview

This exercise focuses on using Terraform resource meta-arguments with Google Cloud Platform (GCP) resources. Meta-arguments are special arguments that change the behavior of resources and provide powerful capabilities for infrastructure management.

## Objectives

In this exercise, you will:

1. Use the `count` meta-argument to create multiple similar resources
2. Use the `for_each` meta-argument to create multiple resources from a map or set
3. Configure resource lifecycle behavior with the `lifecycle` meta-argument
4. Manage dependencies between resources with the `depends_on` meta-argument
5. Use multiple provider configurations for different GCP regions
6. Create conditional resources based on input variables

## Prerequisites

Before starting this exercise, ensure you have:

1. Terraform installed (version 1.0.0 or later)
2. A Google Cloud Platform account
3. GCP project with billing enabled
4. Google Cloud SDK installed and configured
5. Proper IAM permissions to create GCP resources

## Architecture

You will create a multi-region GCP infrastructure including:

- **Primary Region**:
  - VPC Network with subnets in multiple zones
  - Compute instances created using `count`
  - Cloud Storage buckets created using `for_each`
  - Cloud SQL instance with lifecycle rules
  - Firewall rules for different tiers

- **Secondary Region** (optional):
  - Secondary VPC Network
  - Subnet
  - Compute Instance

## Instructions

### Step 1: Review Starter Code

The starter code includes:
- `main.tf`: Primary resource definitions
- `variables.tf`: Variable definitions
- `outputs.tf`: Output definitions
- `versions.tf`: Provider and Terraform version constraints
- `terraform.tfvars`: Variable values

### Step 2: Explore `count` Meta-Argument

The starter code uses `count` to create multiple VM instances:

```hcl
resource "google_compute_instance" "web" {
  count        = length(var.instance_names)
  name         = var.instance_names[count.index]
  machine_type = var.machine_type
  zone         = var.zones[count.index % length(var.zones)]
  
  # Additional configuration...
}
```

### Step 3: Implement `for_each` Meta-Argument

Add a new resource using `for_each` with a map:

```hcl
resource "google_storage_bucket" "environments" {
  for_each = var.environments

  name     = "terraform-meta-args-${var.project_id}-${each.key}-${random_string.bucket_suffix.result}"
  location = each.value.location

  # Additional configuration...
}
```

### Step 4: Configure Lifecycle Rules

Add lifecycle rules to resources:

```hcl
lifecycle {
  prevent_destroy = true
  create_before_destroy = true
  ignore_changes = [
    labels["updated_at"]
  ]
}
```

### Step 5: Add Explicit Dependencies

Use `depends_on` to establish explicit dependencies:

```hcl
depends_on = [
  google_compute_network.main,
  google_compute_subnetwork.main
]
```

### Step 6: Configure Multiple Providers

Define and use multiple provider configurations:

```hcl
provider "google" {
  project = var.project_id
  region  = var.primary_region
}

provider "google" {
  alias   = "secondary"
  project = var.project_id
  region  = var.secondary_region
}

resource "google_compute_network" "secondary" {
  provider = google.secondary
  # Configuration...
}
```

### Step 7: Create Conditional Resources

Add conditional resources based on input variables:

```hcl
resource "google_compute_network" "secondary" {
  count    = var.enable_secondary_region ? 1 : 0
  provider = google.secondary
  # Configuration...
}
```

### Step 8: Test Your Configuration

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Validate your configuration:
   ```bash
   terraform validate
   ```

3. Plan your changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

5. Test different variable values to see how they affect resource creation.

## Challenge Tasks

1. Add Cloud Storage buckets using `for_each` with a set
2. Create firewall rules for different tiers using `for_each`
3. Implement all three lifecycle settings in different resources
4. Create a resource that depends on multiple other resources
5. Use conditional expressions with `count` and `for_each`
6. Create multi-region resources with different configurations

## Additional Resources

- [Terraform Meta-Arguments Documentation](https://www.terraform.io/docs/language/meta-arguments/index.html)
- [Count Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/count.html)
- [For_Each Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/for_each.html)
- [Lifecycle Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html)
- [Depends_On Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/depends_on.html)
- [Multiple Provider Configurations](https://www.terraform.io/docs/language/providers/configuration.html)
- [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)