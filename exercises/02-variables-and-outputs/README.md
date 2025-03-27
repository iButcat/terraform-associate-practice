# Exercise 2: Variables and Outputs in Terraform

## Objective

Learn how to use variables and outputs in Terraform to make configurations more flexible, maintainable, and reusable. This exercise will help you understand variable types, default values, validation, and output formatting.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- Completion of Exercise 1: Your First Terraform Configuration
- For AWS: Access key and secret key with appropriate permissions
- For GCP: Google Cloud account with a project and appropriate credentials

## Cloud Provider Selection

This exercise provides implementations for both AWS and GCP. Choose the cloud provider you're most comfortable with or need to learn for your professional requirements:

- [AWS Implementation](./aws/README.md)
- [GCP Implementation](./gcp/README.md)

## Core Concepts Covered

Regardless of the cloud provider chosen, this exercise covers these key Terraform concepts:

1. **Variable Types**
   - Basic types (string, number, bool)
   - Complex types (list, set, map, object, tuple)
   - Optional vs required variables
   - Type constraints and validation

2. **Variable Definition Methods**
   - Default values in variable blocks
   - Value assignment in `.tfvars` files
   - Command-line assignment with `-var`
   - Environment variables
   - Variable precedence

3. **Outputs**
   - Basic output formatting
   - Output dependencies
   - Sensitive outputs
   - Complex output structures

4. **Local Values**
   - Defining local values
   - Using locals for computed values
   - Reducing repetition with locals

## Exercise Overview

In both AWS and GCP implementations, you will:

1. Create variable definitions with different types
2. Implement variable validation
3. Create a `.tfvars` file for variable assignment
4. Use variables throughout your configuration
5. Define outputs to extract important information
6. Use locals for computed or repeated values
7. Apply the configuration using different variable passing methods

## Learning Outcomes

After completing this exercise, you should be able to:

1. Define and use different variable types
2. Implement variable validation
3. Understand variable precedence
4. Create useful and well-formatted outputs
5. Apply local values effectively
6. Manage configurations for different environments

## Additional Challenges

To further enhance your learning, try these additional challenges after completing the basic exercise:

1. Create environment-specific `.tfvars` files (dev, test, prod)
2. Implement complex validation rules for variables
3. Create outputs that combine multiple resource attributes
4. Use `for` expressions in locals to transform data
5. Create a module that accepts variables and returns outputs

## Next Steps

After completing this exercise, proceed to [Exercise 3: Resource Dependencies](../03-resource-dependencies/README.md), where you'll learn how to manage dependencies between resources in Terraform. 