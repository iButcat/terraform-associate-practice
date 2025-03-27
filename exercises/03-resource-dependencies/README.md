# Exercise 3: Resource Dependencies in Terraform

## Objectives

In this exercise, you will:
1. Learn about implicit and explicit dependencies in Terraform
2. Understand how to use `depends_on` meta-argument
3. Use `terraform graph` to visualize the dependency graph
4. Work with dependent resources across different provider types
5. Understand how dependencies affect resource creation and destruction order

## Prerequisites

- Completion of Exercise 1 (First Configuration) and Exercise 2 (Variables and Outputs)
- Terraform CLI installed (version 1.0.0 or newer)
- AWS CLI configured with appropriate credentials (for AWS implementation)
- GCP project setup with credentials configured (for GCP implementation)

## Core Concepts

### Implicit Dependencies

Terraform automatically determines dependencies between resources when one resource references attributes of another. For example, when a subnet references a VPC's ID, Terraform understands that the VPC must exist before the subnet can be created.

### Explicit Dependencies

Sometimes dependencies aren't obvious from the configuration. In these cases, you can use the `depends_on` meta-argument to explicitly declare a dependency.

### Dependency Graph

Terraform builds a dependency graph to determine the order in which resources should be created, modified, or destroyed. You can visualize this graph using the `terraform graph` command.

## Exercise Overview

In this exercise, you will create a Terraform configuration that demonstrates both implicit and explicit dependencies. You'll build a multi-component system and explore how dependencies affect the order of operations.

The exercise includes implementations for both AWS and GCP, allowing you to choose the cloud provider you're most comfortable with.

## Step 1: Examine the Configuration Files

Before making any changes, review the starter files to understand the resources that will be created and their relationships.

## Step 2: Identify Implicit Dependencies

In the main configuration file, identify the implicit dependencies between resources. Consider:
- Which resources reference attributes of other resources?
- How does Terraform determine the order in which resources should be created?

## Step 3: Add Explicit Dependencies

Modify the configuration to add explicit dependencies using the `depends_on` meta-argument. Consider scenarios where:
- A resource logically depends on another, but doesn't reference its attributes
- A resource depends on multiple other resources
- Dependencies that may not be obvious from the configuration

## Step 4: Visualize the Dependency Graph

Use the `terraform graph` command to visualize the dependency graph of your configuration. This will help you understand how Terraform plans to create, modify, or destroy resources.

```bash
terraform graph | dot -Tpng > graph.png
```

Note: You'll need Graphviz installed to convert the output to an image.

## Step 5: Test Resource Creation Order

Apply the configuration and observe the order in which resources are created. Does this match your expectations based on the dependencies you identified?

## Step 6: Test Resource Destruction Order

Plan a destroy operation and observe the order in which resources would be destroyed. Note that destruction happens in the reverse order of creation.

```bash
terraform plan -destroy
```

## Learning Outcomes

After completing this exercise, you will:
- Understand how Terraform manages resource dependencies
- Be able to identify implicit dependencies in a configuration
- Know when and how to use explicit dependencies
- Understand how dependencies affect the order of operations
- Be able to visualize and interpret Terraform's dependency graph

## Additional Challenges

1. Create a configuration with circular dependencies and observe how Terraform handles them
2. Experiment with the `terraform graph` command's different output formats
3. Create a configuration where a resource depends on another resource's data, not just its existence
4. Implement a configuration that demonstrates dependencies across different provider types

## Next Steps

After completing this exercise, move on to Exercise 4: Working with State, where you'll learn about Terraform's state management capabilities. 