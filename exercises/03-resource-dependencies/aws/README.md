# Exercise 3: Resource Dependencies in Terraform (AWS)

## Objectives

In this exercise, you will learn how to:

1. Create a multi-tier architecture with AWS resources
2. Identify and understand implicit dependencies in Terraform
3. Add explicit dependencies using the `depends_on` meta-argument
4. Visualize the dependency graph of your resources
5. Understand how dependencies affect the order of resource creation and destruction

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Basic understanding of AWS services (VPC, EC2, RDS, S3, IAM)

## Instructions

### Step 1: Review the Starter Code

1. Examine the starter files in the `starter` directory:
   - `main.tf`: Contains AWS resources with implicit dependencies
   - `variables.tf`: Defines input variables
   - `outputs.tf`: Defines output values
   - `versions.tf`: Sets required providers and versions
   - `terraform.tfvars`: Sets variable values

2. Identify the resources defined in `main.tf`:
   - VPC and Networking components (subnets, internet gateway, route tables)
   - Security Groups
   - EC2 instance (web server)
   - RDS instance (database)
   - S3 bucket (for application assets)

### Step 2: Identify Implicit Dependencies

Terraform automatically creates an implicit dependency graph based on references between resources. For example:

- Subnets depend on the VPC because they reference `aws_vpc.main.id`
- Security groups depend on the VPC for the same reason
- The EC2 instance depends on the public subnet and security group

Take some time to identify these implicit dependencies in the starter code.

### Step 3: Add Explicit Dependencies

1. Copy the starter files to your working directory
2. Modify `main.tf` to add explicit dependencies using the `depends_on` meta-argument where appropriate:
   - Add dependencies for networking resources
   - Add dependencies for compute and database resources
   - Add dependencies for storage and IAM resources
3. Add additional resources to enhance the architecture:
   - IAM roles and policies
   - Additional security measures
   - Instance profiles

### Step 4: Visualize the Dependency Graph

Use the Terraform graph command to visualize your dependency graph:

```bash
terraform graph | dot -Tpng > aws_dependencies.png
```

This requires the `graphviz` package to be installed. Alternatively, you can use online tools to render the output of `terraform graph`.

### Step 5: Test Your Dependencies

1. Initialize your Terraform configuration:
   ```bash
   terraform init
   ```

2. Validate your configuration:
   ```bash
   terraform validate
   ```

3. Create a plan to see the order of resource creation:
   ```bash
   terraform plan
   ```

4. Apply your configuration:
   ```bash
   terraform apply
   ```

5. Observe the order in which resources are created.

6. When you're finished, destroy the resources:
   ```bash
   terraform destroy
   ```

7. Observe the order in which resources are destroyed (reverse of creation).

## Challenges

After completing the basic exercise, try these additional challenges:

1. **Multi-Region Deployment**: Extend your configuration to deploy resources in a second AWS region, establishing dependencies between the regions.

2. **CloudWatch Dashboard**: Create a CloudWatch dashboard for your resources with appropriate dependencies.

3. **Circular Dependency**: Attempt to create a circular dependency and understand how Terraform handles it.

4. **Custom IAM Roles**: Add more complex IAM roles with policies that reference created resources.

5. **Data Sources**: Use data sources to create dependencies on existing resources in your AWS account.

## Resources

- [Terraform Resource Dependencies Documentation](https://www.terraform.io/docs/language/resources/dependencies.html)
- [Terraform Resource Behavior Documentation](https://www.terraform.io/docs/language/resources/behavior.html)
- [Terraform Graph Documentation](https://www.terraform.io/docs/cli/commands/graph.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html) 