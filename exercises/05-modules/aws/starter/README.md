# Exercise 5: Terraform Modules

## Overview
This exercise focuses on using Terraform modules to organize and reuse infrastructure code. You'll work with three interconnected modules (VPC, Web, and Database) to build a complete application stack.

## Objectives
- Understand modular infrastructure design
- Implement module inputs and outputs
- Practice module composition and reuse
- Learn module versioning and sourcing

## Architecture
The starter code provides a three-tier architecture using AWS resources:
- **VPC Module**: Creates the network foundation with public and private subnets
- **Web Module**: Deploys EC2 instances in public subnets with a security group
- **Database Module**: Sets up an RDS instance in private subnets

## Instructions
1. Review the existing module structure in the `/modules` directory
2. Examine how the root module (`main.tf`) references and composes the child modules
3. Understand how variables are passed into modules and how outputs are referenced
4. Initialize and apply the Terraform configuration:
   ```
   terraform init
   terraform plan
   terraform apply
   ```
5. After successful deployment, use `terraform output` to see the outputs from all modules

## Challenge Tasks
1. Add a new module for an Application Load Balancer (ALB) to distribute traffic to web instances
2. Modify the web module to use an Auto Scaling Group instead of fixed instances
3. Add S3 backend configuration to store state remotely
4. Add conditional creation of resources within one of the modules
5. Create a versioned module in a separate repository and reference it

## Resources
- [Terraform Module Documentation](https://developer.hashicorp.com/terraform/language/modules)
- [Module Composition](https://developer.hashicorp.com/terraform/language/modules/develop/composition)
- [AWS Modules in Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Module Sources](https://developer.hashicorp.com/terraform/language/modules/sources) 