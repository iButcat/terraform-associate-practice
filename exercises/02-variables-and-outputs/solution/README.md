# Exercise 2: Variables and Outputs - Solution

This directory contains the solution for Exercise 2, demonstrating how to work with Terraform variables and outputs to make configurations more flexible, reusable, and informative.

## Solution Overview

This solution showcases:

1. **Various Variable Types**:
   - Basic types (string, number, bool)
   - Complex types (list, map, object)
   - Variable validation
   - Sensitive variables

2. **Variable Organization**:
   - Variables defined in `variables.tf`
   - Default values set in variable declarations
   - Values overridden in `.tfvars` files
   - Environment-specific configurations in `prod.tfvars`

3. **Dynamic Resource Creation**:
   - Using `count` with variables
   - Using `for_each` through dynamic blocks
   - Conditional resource creation

4. **Output Techniques**:
   - Basic outputs
   - Formatted outputs using functions
   - Conditional outputs
   - Complex structured outputs

5. **Local Values**:
   - Using `locals` for computed values
   - Reusing local values in multiple places

## Key Files

- `variables.tf` - Defines all input variables
- `main.tf` - Contains the resource definitions
- `outputs.tf` - Defines all output values
- `versions.tf` - Sets provider and Terraform version constraints
- `terraform.tfvars` - Default variable values
- `prod.tfvars` - Production-specific variable values

## Using This Solution

### Basic Usage

```bash
terraform init
terraform apply
```

### Using Production Variables

```bash
terraform apply -var-file=prod.tfvars
```

### Overriding Specific Variables

```bash
terraform apply -var="instance_count=3" -var="environment=test"
```

## Learning Points

1. **Variable Types and Validation**
   - Understanding the different variable types and when to use them
   - Adding validation to ensure input values meet requirements

2. **Value Assignment Methods**
   - Default values in variable declarations
   - Values in .tfvars files
   - Command-line overrides with `-var` and `-var-file`

3. **Dynamic Configuration**
   - Using variables to control resource creation
   - Implementing dynamic blocks for repeated nested configurations

4. **Output Techniques**
   - Providing useful information about created resources
   - Using functions to format outputs
   - Conditional outputs based on configuration

5. **Local Values**
   - Computing and reusing values within the configuration
   - Simplifying complex expressions 