# Exercise 6: Terraform Resource Meta-Arguments (Solution)

## Overview

This solution demonstrates the advanced use of Terraform resource meta-arguments to create, manage, and configure AWS resources. Meta-arguments are special arguments that change the behavior of resources and provide powerful capabilities for infrastructure management.

## Key Meta-Arguments Demonstrated

1. **count**: Used to create multiple similar resources
2. **for_each**: Used to create multiple resources from a map or set
3. **lifecycle**: Customizes resource lifecycle behavior
4. **depends_on**: Explicitly defines dependencies between resources
5. **provider**: Specifies a non-default provider configuration
6. **provisioner**: Executes actions on resources
7. **aliases**: Configures multiple providers of the same type

## Architecture

This solution creates a multi-region AWS infrastructure including:

- **Primary Region**:
  - VPC with multiple public subnets
  - Internet Gateway with appropriate routing
  - Web servers using count
  - Security groups for different tiers using for_each
  - RDS database with lifecycle rules
  - S3 buckets for different environments using for_each
  - Elastic IP with create_before_destroy lifecycle

- **Secondary Region** (optional):
  - Secondary VPC
  - Public subnet
  - EC2 instance

## Key Features

### 1. Resource Creation with `count`

The solution uses the `count` meta-argument to create multiple similar resources:

```hcl
resource "aws_subnet" "public" {
  count = length(var.subnet_cidrs)
  # Configuration...
}

resource "aws_instance" "web" {
  count = length(var.instance_names)
  # Configuration...
}
```

### 2. Dynamic Resource Creation with `for_each`

The `for_each` meta-argument is used to create multiple resources from a map or set:

```hcl
resource "aws_s3_bucket" "environments" {
  for_each = var.environments
  bucket   = "terraform-meta-args-${var.environment}-${each.key}-${random_string.bucket_suffix.result}"
  # Configuration...
}

resource "aws_security_group" "tiers" {
  for_each = toset(["web", "app", "db"])
  # Configuration...
}
```

### 3. Lifecycle Management

Various lifecycle rules are demonstrated:

```hcl
lifecycle {
  ignore_changes = [
    tags["UpdatedAt"]
  ]
}

lifecycle {
  prevent_destroy = true
}

lifecycle {
  create_before_destroy = true
}
```

### 4. Explicit Dependencies with `depends_on`

Explicit dependencies are defined using the `depends_on` meta-argument:

```hcl
resource "aws_instance" "backend" {
  # Configuration...
  depends_on = [
    aws_subnet.public,
    aws_internet_gateway.main,
    aws_db_instance.main
  ]
}
```

### 5. Multiple Providers

The solution demonstrates the use of multiple providers with aliases:

```hcl
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "west"
  region = var.secondary_region
}

resource "aws_vpc" "secondary" {
  provider = aws.west
  # Configuration...
}
```

### 6. Conditional Resource Creation

Resources are conditionally created based on variable values:

```hcl
resource "aws_vpc" "secondary" {
  count    = var.enable_secondary_region ? 1 : 0
  provider = aws.west
  # Configuration...
}
```

## How to Use

1. Review the code to understand the implementation of each meta-argument
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the changes:
   ```bash
   terraform plan
   ```
4. Apply the changes:
   ```bash
   terraform apply
   ```
5. Experiment by modifying:
   - The `instance_names` variable to add or remove web servers
   - The `environments` map to add or remove S3 buckets
   - The `enable_secondary_region` variable to toggle secondary region resources

## Learning Goals

Through this solution, you'll learn how to:

1. Create multiple resources efficiently using `count` and `for_each`
2. Control resource lifecycle behavior
3. Manage dependencies between resources
4. Work with multiple provider configurations
5. Create resources conditionally
6. Generate dynamic resource names and configurations

## Additional Resources

- [Terraform Meta-Arguments Documentation](https://www.terraform.io/docs/language/meta-arguments/index.html)
- [Count Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/count.html)
- [For_Each Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/for_each.html)
- [Lifecycle Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html)
- [Depends_On Meta-Argument](https://www.terraform.io/docs/language/meta-arguments/depends_on.html)
- [Multiple Provider Configurations](https://www.terraform.io/docs/language/providers/configuration.html) 