# Exercise 6: Resource Meta-Arguments

## Overview
This exercise focuses on Terraform resource meta-arguments, which modify how Terraform manages resources. The starter code demonstrates using the `count` meta-argument to create multiple similar resources.

## Objectives
- Understand and implement the `count` meta-argument
- Learn how to use the `for_each` meta-argument
- Configure resource `lifecycle` settings
- Manage resource dependencies with `depends_on`
- Work with multiple providers using the `provider` meta-argument
- Prevent resource destruction with lifecycle settings

## Architecture
The starter code creates a simple AWS infrastructure with:
- A VPC with multiple public subnets (using count)
- An Internet Gateway and Route Table
- A Security Group for web traffic
- Multiple EC2 instances (using count)

## Instructions
1. Review the existing code and understand how the `count` meta-argument is used
2. Initialize and apply the Terraform configuration:
   ```
   terraform init
   terraform plan
   terraform apply
   ```
3. Extend the code to include:
   - `for_each` with a set or map to create resources
   - `lifecycle` blocks with settings like `create_before_destroy`, `prevent_destroy`, and `ignore_changes`
   - Explicit `depends_on` relationships
   - Multiple provider configurations

## Challenge Tasks
1. Create a set of S3 buckets using `for_each` with a map of settings
2. Create security groups using `for_each` with a set of strings
3. Add lifecycle management to protect critical resources
4. Create resources in a secondary region using an aliased provider
5. Implement conditional creation of resources using count and a boolean variable

## Resources
- [Count Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/count)
- [For_Each Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Lifecycle Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Depends_On Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on)
- [Provider Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/resource-provider) 