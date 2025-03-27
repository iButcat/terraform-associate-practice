# Core Terraform Workflow

The core Terraform workflow consists of writing configuration, planning changes, and applying those changes to create or modify infrastructure. This is often abbreviated as "Write, Plan, Apply."

## Understanding the Terraform Workflow

### The Write -> Plan -> Create Workflow

1. **Write** - Author Terraform configuration files (*.tf)
   - Define infrastructure resources
   - Specify provider settings
   - Set up variables and outputs

2. **Plan** - Preview changes before applying
   - Terraform reads the current state
   - Compares it to desired state in configuration
   - Shows what changes will be made

3. **Create (Apply)** - Execute the planned changes
   - Create, update, or delete resources
   - Update state file
   - Output results

### Workflow Example

```bash
# Write configuration in main.tf and other files

# Initialize the working directory
terraform init

# Validate the configuration 
terraform validate

# Create an execution plan
terraform plan

# Apply the changes
terraform apply

# When done with the infrastructure
terraform destroy
```

## Initialize a Terraform Working Directory (terraform init)

### Purpose of Initialization

The `terraform init` command prepares a working directory for other Terraform commands by:

1. Downloading provider plugins
2. Setting up backend for state storage
3. Downloading modules

### Basic Initialization

```bash
terraform init
```

### Common Options

```bash
# Force reconfiguration of backend
terraform init -reconfigure

# Upgrade modules and plugins to latest versions
terraform init -upgrade

# Use specific plugin directory
terraform init -plugin-dir=PATH

# Suppress interactive prompts
terraform init -input=false
```

### Understanding the Dependency Lock File

The `.terraform.lock.hcl` file:
- Created/updated during initialization
- Locks provider versions for consistent builds
- Should be committed to version control
- Records provider versions, hashes, and constraints

Example lock file:
```hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "4.16.0"
  constraints = "~> 4.16.0"
  hashes = [
    "h1:6V8jLqXdtHjCkMIuxg77BrTVchqpaRK1UUYeTuXDPmE=",
    "zh:0aa204fead7c431796386cc9e73ccda9a7d8cb25d2ad780455e3ba36030b02ea",
    # additional hash values...
  ]
}
```

## Validate a Terraform Configuration (terraform validate)

### Purpose of Validation

The `terraform validate` command verifies whether a configuration is syntactically valid and internally consistent, checking:
- Syntax errors
- Attribute names and types
- Resource references
- Expression validity

### Basic Validation

```bash
terraform validate
```

### Validation Process

1. Terraform checks syntax of HCL files
2. Confirms all references to variables, resources, and modules are valid
3. Verifies attribute values are of the correct type
4. Reports errors if validation fails

### Example Validation Output

Successful validation:
```
Success! The configuration is valid.
```

Failed validation:
```
Error: Reference to undeclared resource

  on main.tf line 24, in resource "aws_subnet" "example":
  24:   vpc_id = aws_vpc.main.id

A managed resource "aws_vpc" "main" has not been declared in the root module.
```

## Generate and Review an Execution Plan (terraform plan)

### Purpose of Planning

The `terraform plan` command:
- Shows what changes Terraform will make
- Compares current state with desired configuration
- Allows review before applying changes
- Identifies potential issues

### Basic Planning

```bash
terraform plan
```

### Common Options

```bash
# Save plan to a file
terraform plan -out=tfplan

# Set variables during plan
terraform plan -var="instance_count=5"

# Use a variable file
terraform plan -var-file="prod.tfvars"

# Show detailed plan output
terraform plan -detailed-exitcode
```

### Understanding Plan Output

The plan output shows:
1. Resources to be created (`+` prefix)
2. Resources to be destroyed (`-` prefix)
3. Resources to be modified (`~` prefix)
4. Resources to be replaced (`-/+` prefix)

Example plan output:
```
Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                          = "ami-0c55b159cbfafe1f0"
      + instance_type                = "t2.micro"
      + tags                         = {
          + "Name" = "example-instance"
        }
      # (additional attributes hidden)
    }

  # aws_security_group.example will be updated in-place
  ~ resource "aws_security_group" "example" {
      ~ description = "Old description" -> "New description"
        id          = "sg-0123456789abcdef"
        name        = "example"
        # (additional attributes unchanged)
    }

Plan: 1 to add, 1 to change, 0 to destroy.
```

## Execute Changes to Infrastructure (terraform apply)

### Purpose of Apply

The `terraform apply` command:
- Creates, updates, or destroys resources to match configuration
- Updates the state file with the new infrastructure state
- Outputs the results of the operation

### Basic Apply

```bash
terraform apply
```

### Common Options

```bash
# Apply a saved plan
terraform apply tfplan

# Auto-approve without confirmation prompt
terraform apply -auto-approve

# Set variables during apply
terraform apply -var="environment=production"

# Target specific resources
terraform apply -target=aws_instance.web
```

### Apply Process

1. By default, Terraform generates a new plan
2. Shows the plan and asks for confirmation
3. If approved, executes the changes
4. Updates the state file
5. Shows outputs defined in the configuration

### Example Apply Output

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.example: Creating...
aws_instance.example: Creation complete after 45s [id=i-1234567890abcdef0]
aws_security_group.example: Modifying... [id=sg-0123456789abcdef]
aws_security_group.example: Modifications complete after 12s [id=sg-0123456789abcdef]

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.

Outputs:

instance_ip = "203.0.113.10"
```

## Destroy Terraform Managed Infrastructure (terraform destroy)

### Purpose of Destroy

The `terraform destroy` command:
- Removes all resources defined in the configuration
- Updates the state file to reflect the deletions
- Is a safer alternative to manually deleting resources

### Basic Destroy

```bash
terraform destroy
```

### Common Options

```bash
# Auto-approve without confirmation prompt
terraform destroy -auto-approve

# Target specific resources
terraform destroy -target=aws_instance.web

# Set variables during destroy
terraform destroy -var="environment=dev"
```

### Destroy Process

1. Terraform generates a destroy plan
2. Shows the plan and asks for confirmation
3. If approved, deletes all resources in the right order
4. Updates the state file to remove the resources

### Example Destroy Output

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_security_group.example: Destroying... [id=sg-0123456789abcdef]
aws_security_group.example: Destruction complete after 15s
aws_instance.example: Destroying... [id=i-1234567890abcdef0]
aws_instance.example: Destruction complete after 50s

Destroy complete! Resources: 2 destroyed.
```

## Apply Formatting and Style Adjustments (terraform fmt)

### Purpose of Formatting

The `terraform fmt` command:
- Automatically formats Terraform configuration files
- Ensures consistent style across files
- Makes configurations more readable
- Follows HashiCorp's style conventions

### Basic Format

```bash
terraform fmt
```

### Common Options

```bash
# Check if files are formatted correctly without modifying
terraform fmt -check

# Include subdirectories
terraform fmt -recursive

# Show which files were modified
terraform fmt -diff

# Write to stdout instead of updating files
terraform fmt -write=false
```

### Formatting Rules

Terraform fmt applies consistent formatting rules:
- Two-space indentation
- Aligned equal signs for consecutive arguments
- Alphabetical ordering of blocks with the same type
- Standardized spacing and newlines

### Example Before and After Formatting

Before:
```hcl
resource "aws_instance" "web" {
ami           = "ami-0c55b159cbfafe1f0"
instance_type   =     "t2.micro"
    tags = {
        Name="web-server"
    Environment="production"
    }
}
```

After:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Environment = "production"
    Name        = "web-server"
  }
}
```

## Core Workflow Best Practices

### Version Control Integration

1. **Commit Configuration Files**
   - Store all `.tf` files in version control
   - Include `.terraform.lock.hcl` file
   - Exclude `.terraform/` directory

2. **Use Branches for Changes**
   - Make infrastructure changes in feature branches
   - Review changes via pull requests
   - Merge only after successful `terraform plan`

### CI/CD Integration

1. **Automated Validation**
   - Run `terraform validate` and `terraform fmt -check` in CI pipelines
   - Include static code analysis tools

2. **Plan in CI, Apply in CD**
   - Generate and review plans in CI
   - Apply changes only after approval
   - Store plan artifacts for traceability

### Common Workflow Patterns

1. **Review-then-apply Pattern**
   ```bash
   terraform plan -out=tfplan
   # Review the plan
   terraform apply tfplan
   ```

2. **Environment-specific Pattern**
   ```bash
   terraform plan -var-file=environments/prod.tfvars
   terraform apply -var-file=environments/prod.tfvars
   ```

3. **Targeted Changes Pattern**
   ```bash
   terraform plan -target=module.frontend
   terraform apply -target=module.frontend
   ```

## Key Points for the Exam

1. The core Terraform workflow is Write -> Plan -> Apply
2. `terraform init` initializes a working directory and downloads required providers and modules
3. The `.terraform.lock.hcl` file locks provider versions and should be committed to version control
4. `terraform validate` checks syntax and validity without accessing remote state or providers
5. `terraform plan` shows what changes will be made before applying
6. `terraform apply` executes the planned changes and updates the state
7. `terraform destroy` removes all resources defined in the configuration
8. `terraform fmt` standardizes formatting for better readability
9. Always review plans carefully before applying changes 