# Exercise 6: Terraform Resource Meta-Arguments (GCP Solution)

## Overview

This solution demonstrates the advanced use of Terraform resource meta-arguments to create, manage, and configure Google Cloud Platform resources. Meta-arguments are special arguments that change the behavior of resources and provide powerful capabilities for infrastructure management.

## Key Meta-Arguments Demonstrated

1. **count**: Used to create multiple similar resources
2. **for_each**: Used to create multiple resources from a map or set
3. **lifecycle**: Customizes resource lifecycle behavior
4. **depends_on**: Explicitly defines dependencies between resources
5. **provider**: Specifies a non-default provider configuration
6. **aliases**: Configures multiple providers of the same type

## Architecture

This solution creates a multi-region GCP infrastructure including:

- **Primary Region**:
  - VPC Network with multiple subnets (using count)
  - Compute Engine instances (using count)
  - Cloud Storage buckets for different environments (using for_each with a map)
  - Cloud Storage buckets for logging (using for_each with a set)
  - Cloud SQL database with lifecycle rules
  - Firewall rules for different tiers (using for_each)

- **Secondary Region** (optional):
  - Secondary VPC Network
  - Subnet
  - Compute Engine instance

## Key Features

### 1. Resource Creation with `count`

The solution uses the `count` meta-argument to create multiple similar resources:

```hcl
resource "google_compute_subnetwork" "main" {
  count         = length(var.subnet_cidrs)
  name          = "${var.environment}-subnet-${count.index}"
  ip_cidr_range = var.subnet_cidrs[count.index]
  # Configuration...
}

resource "google_compute_instance" "web" {
  count        = length(var.instance_names)
  name         = var.instance_names[count.index]
  # Configuration...
}
```

### 2. Dynamic Resource Creation with `for_each`

The `for_each` meta-argument is used to create multiple resources from a map or set:

```hcl
resource "google_storage_bucket" "environments" {
  for_each = var.environments
  name     = "terraform-meta-args-${var.project_id}-${each.key}-${random_string.bucket_suffix.result}"
  # Configuration...
}

resource "google_storage_bucket" "logging" {
  for_each = toset(["access", "error", "debug"])
  # Configuration...
}

resource "google_compute_firewall" "tiers" {
  for_each = toset(["web", "app", "db"])
  # Configuration...
}
```

### 3. Lifecycle Management

Various lifecycle rules are demonstrated:

```hcl
lifecycle {
  create_before_destroy = true
}

lifecycle {
  prevent_destroy = true
}

lifecycle {
  ignore_changes = [
    labels["updated_at"],
    password
  ]
}
```

### 4. Explicit Dependencies with `depends_on`

Explicit dependencies are defined using the `depends_on` meta-argument:

```hcl
resource "google_compute_instance" "backend" {
  # Configuration...
  depends_on = [
    google_compute_subnetwork.main,
    google_sql_database_instance.main
  ]
}

resource "google_sql_database_instance" "main" {
  # Configuration...
  depends_on = [
    google_compute_network.main
  ]
}
```

### 5. Multiple Providers

The solution demonstrates the use of multiple providers with aliases:

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

### 6. Conditional Resource Creation

Resources are conditionally created based on variable values:

```hcl
resource "google_compute_network" "secondary" {
  count    = var.enable_secondary_region ? 1 : 0
  provider = google.secondary
  # Configuration...
}
```

## Additional Resources

- [Terraform Meta-Arguments Documentation](https://www.terraform.io/docs/language/meta-arguments/index.html)
- [Count Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/count.html)
- [For_Each Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/for_each.html)
- [Lifecycle Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html)
- [Depends_On Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/depends_on.html)
- [Multiple Provider Configurations](https://www.terraform.io/docs/language/providers/configuration.html)
- [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs) 