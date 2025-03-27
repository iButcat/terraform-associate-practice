# Exercise 3: Resource Dependencies (GCP Implementation)

This directory contains the GCP implementation for Exercise 3, focusing on resource dependencies in Terraform.

## Objectives

In this GCP-specific implementation, you will:

1. Create a multi-tier architecture with VPC network, subnets, instances, and databases
2. Explore implicit dependencies through resource references
3. Add explicit dependencies using the `depends_on` meta-argument
4. Visualize the dependency graph for your GCP infrastructure
5. Understand how dependencies affect the order of resource creation and destruction

## Instructions

### Step 1: Review the Starter Code

The starter directory contains a basic setup for a web application infrastructure on GCP:
- VPC network and subnetworks
- Firewall rules
- Compute instances for a web tier
- Cloud SQL instance for a database tier

Review the files to understand the infrastructure components and identify existing dependencies.

### Step 2: Identify Implicit Dependencies

Examine the relationships in the code:
- Which resources reference attributes of other resources?
- What is the dependency chain for the infrastructure components?
- How will Terraform determine the creation order?

Make a note of the implicit dependencies you find. Common examples include:
- Subnetworks referencing a VPC network
- Firewall rules referencing the VPC network
- Compute instances referencing subnetwork IDs
- Cloud SQL instances referencing network configurations

### Step 3: Add Explicit Dependencies

The starter code has intentionally omitted some explicit dependencies. Modify the configuration to add appropriate `depends_on` meta-arguments where needed. Consider:

1. Update the Compute instances to depend on firewall rules
   - This ensures the firewall rules are in place before instances start
   
2. Make the Cloud SQL instance depend on the private service networking connection
   - This clarifies the dependency relationship, even though it may be partially implicit

3. Add dependencies to the load balancer components
   - Make sure all dependencies are properly set for the load balancer, backend services, and health checks

### Step 4: Visualize and Analyze the Dependency Graph

Generate a visual representation of your dependency graph:

```bash
terraform graph | dot -Tpng > gcp_dependencies.png
```

Analyze the graph to understand:
- The dependency chains in your infrastructure
- Which resources will be created first
- Which resources can be created in parallel
- The effect of your explicit dependencies

### Step 5: Test the Dependencies

1. Initialize and validate your configuration:
   ```bash
   terraform init
   terraform validate
   ```

2. Create a plan and review the creation order:
   ```bash
   terraform plan
   ```

3. Apply the configuration (if in a test environment):
   ```bash
   terraform apply
   ```

4. Observe the order of creation and how Terraform manages dependencies.

5. Plan a destroy operation to see the destruction order:
   ```bash
   terraform plan -destroy
   ```

## Challenges

1. Add a second region deployment that depends on the successful creation of resources in the first region
2. Create a Cloud Monitoring dashboard that depends on all the other resources being created
3. Implement a circular dependency and observe how Terraform handles it
4. Add custom IAM roles with complex dependency chains
5. Create cross-resource dependencies using data sources

## Solution

Check the `solution` directory for a complete working example after you've attempted the exercise.

## Resources

- [Terraform Resource Dependencies Documentation](https://www.terraform.io/docs/language/resources/dependencies.html)
- [Terraform Resource Behavior Documentation](https://www.terraform.io/docs/language/resources/behavior.html)
- [Terraform Graph Documentation](https://www.terraform.io/docs/cli/commands/graph.html)
- [GCP Resource Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources) 