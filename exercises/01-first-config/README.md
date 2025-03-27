# Exercise 1: Your First Terraform Configuration

## Objective

Learn how to create a basic Terraform configuration, understand the core Terraform workflow, and deploy simple infrastructure to AWS or GCP.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- For AWS: Access key and secret key with appropriate permissions
- For GCP: Google Cloud account with a project and appropriate credentials

## Cloud Provider Selection

This exercise provides implementations for both AWS and GCP. Choose the cloud provider you're most comfortable with or need to learn for your professional requirements:

- [AWS Implementation](./aws/README.md)
- [GCP Implementation](./gcp/README.md)

## Core Concepts Covered

Regardless of the cloud provider chosen, this exercise covers these key Terraform concepts:

1. **Provider Configuration**
   - Setting up Terraform providers
   - Managing provider credentials
   - Provider versioning

2. **Resource Definitions**
   - Basic resource syntax
   - Resource attributes
   - Resource identification

3. **Terraform Workflow**
   - `terraform init` - Initialize working directory
   - `terraform plan` - Create execution plan
   - `terraform apply` - Apply changes
   - `terraform destroy` - Remove resources

4. **State Management**
   - Local state file
   - State inspection

## Exercise Overview

In both AWS and GCP implementations, you will:

1. Create a basic configuration file
2. Configure the appropriate provider
3. Define networking resources (VPC/VNet in AWS, VPC in GCP)
4. Initialize the working directory
5. Create an execution plan
6. Apply the plan to create the resources
7. Verify resource creation
8. Destroy the resources

## Learning Outcomes

After completing this exercise, you should be able to:

1. Write basic Terraform configuration files
2. Understand how to configure cloud providers
3. Create and manage resources through Terraform
4. Execute the core Terraform workflow
5. Read and interpret Terraform plan output
6. Clean up resources to avoid unnecessary costs

## Additional Challenges

To further enhance your learning, try these additional challenges after completing the basic exercise:

1. Add more resources to your configuration (e.g., subnets, security groups)
2. Modify existing resources and observe the plan output
3. Try changing a resource in a way that forces recreation
4. Explore the state file contents using `terraform state list` and `terraform state show`

## Next Steps

After completing this exercise, proceed to [Exercise 2: Variables and Outputs](../02-variables-and-outputs/README.md), where you'll learn how to parameterize your configurations and extract useful information. 