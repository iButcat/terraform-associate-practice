# Terraform Outside the Core Workflow

While Terraform's core workflow (write, plan, apply) covers most use cases, there are important commands and features to use when working with existing infrastructure or troubleshooting issues.

## Using `terraform import` to Import Existing Infrastructure

### What is `terraform import`?

The `terraform import` command brings existing resources under Terraform management by adding them to your Terraform state without recreating them.

### When to Use `terraform import`

Use `terraform import` when:
- Taking over manually created infrastructure
- Migrating from another IaC tool to Terraform
- Recovering from state file loss
- Including resources created outside of Terraform

### Import Process

1. **Write the resource configuration** in your `.tf` files
2. **Run the import command**:
   ```bash
   terraform import [options] ADDRESS ID
   ```
   where:
   - `ADDRESS` is the resource address in your configuration (e.g., `aws_instance.web`)
   - `ID` is the provider-specific ID of the resource (e.g., `i-1234567890abcdef0`)

3. **Verify state** with `terraform state list` and `terraform plan`
4. **Adjust configuration** as needed to match the imported resource

### Example: Importing an AWS S3 Bucket

Configuration in `main.tf`:
```hcl
resource "aws_s3_bucket" "imported_bucket" {
  bucket = "my-existing-bucket"
  
  tags = {
    Environment = "Production"
    Managed_by  = "Terraform"
  }
}
```

Import command:
```bash
terraform import aws_s3_bucket.imported_bucket my-existing-bucket
```

### Import Limitations

- You must write the resource configuration before importing
- Not all resource attributes may be imported
- Complex resources might require multiple import commands
- Provider documentation specifies the expected ID format

## Using `terraform state` Commands

### Key `terraform state` Subcommands

1. **`terraform state list`**
   - Shows all resources in the state file
   - Example: `terraform state list`

2. **`terraform state show`**
   - Displays details of a specific resource
   - Example: `terraform state show aws_instance.web`

3. **`terraform state mv`**
   - Moves resources within the state (rename/restructure)
   - Example: `terraform state mv aws_instance.old aws_instance.new`

4. **`terraform state rm`**
   - Removes a resource from state without destroying it
   - Example: `terraform state rm aws_instance.web`

5. **`terraform state pull`**
   - Outputs the current state to stdout
   - Useful for state inspection or backup
   - Example: `terraform state pull > backup.tfstate`

6. **`terraform state push`**
   - Updates the state from a local file
   - Use with extreme caution
   - Example: `terraform state push restored.tfstate`

### State Management Use Cases

#### Refactoring Terraform Code

When renaming or restructuring resources:
```bash
# Rename a resource
terraform state mv aws_instance.app aws_instance.web_server

# Move a resource into a module
terraform state mv aws_instance.app module.frontend.aws_instance.app
```

#### Fixing State Issues

For resources that need to be reimported or managed separately:
```bash
# Remove a resource from state (to reimport or manage manually)
terraform state rm aws_route53_record.broken

# Export state for debugging
terraform state pull > debug.tfstate
```

#### Splitting State

When breaking a large configuration into smaller ones:
```bash
# List resources to move
terraform state list | grep "module.component_a"

# Remove resources from current state
terraform state rm module.component_a
```

## Using Verbose Logging

### When to Enable Verbose Logging

Enable verbose logging when:
- Debugging Terraform execution issues
- Investigating unexpected behavior
- Understanding resource lifecycle
- Troubleshooting provider API interactions

### Setting Log Levels

Terraform uses the `TF_LOG` environment variable to control logging:

| Log Level | Description |
|-----------|-------------|
| `TRACE`   | Most verbose, shows everything |
| `DEBUG`   | Detailed information about operations |
| `INFO`    | Operation progress information |
| `WARN`    | Warning messages |
| `ERROR`   | Error messages only |

### Enabling Logging

#### For all components:
```bash
export TF_LOG=DEBUG
terraform apply
```

#### For specific components:
```bash
export TF_LOG_CORE=TRACE    # Core Terraform functionality
export TF_LOG_PROVIDER=TRACE # Provider-specific operations
terraform plan
```

### Logging to a File

Redirect logs to a file using `TF_LOG_PATH`:
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply
```

### What Information Logging Provides

1. **TRACE level** shows:
   - Full API requests and responses
   - Detailed provider plugin communication
   - Resource dependency resolution
   - Complete state transformation

2. **DEBUG level** shows:
   - Provider operations
   - Resource creation/modification sequences
   - State file operations

3. **INFO level** shows:
   - High-level operations
   - Resource changes summary

### Example: Debugging Provider Authentication

```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./auth-debug.log
terraform init
```

Examine the log file for authentication errors:
```
grep -i "authentication\|auth\|creds" auth-debug.log
```

## Key Points for the Exam

1. `terraform import` brings existing resources under Terraform management without recreating them
2. Resource configuration must be written before importing
3. `terraform state` commands allow manipulation of state without modifying the actual infrastructure
4. `terraform state mv` is used for refactoring, like renaming resources or moving them into modules
5. `terraform state list` and `terraform state show` are non-destructive and useful for state inspection
6. Verbose logging is enabled using the `TF_LOG` environment variable
7. Log levels include TRACE, DEBUG, INFO, WARN, and ERROR
8. `TF_LOG_PATH` directs logging output to a file 