# Implement and Maintain State

Terraform state is a crucial aspect of managing infrastructure. It tracks the resources Terraform manages, their attributes, and metadata about those resources.

## Understanding Terraform State

### What is Terraform State?

Terraform state is a JSON document that:
- Maps resources in your configuration to real-world infrastructure
- Tracks resource metadata
- Caches resource attributes
- Maintains a record of resource dependencies
- Improves performance of plan/apply operations
- Enables collaboration between team members

By default, Terraform stores state locally in a file named `terraform.tfstate`.

### State Structure

Terraform state consists of:

1. **Version Information**: Metadata about the state format version
2. **Terraform Version**: The version of Terraform that created the state
3. **Serial**: A counter incremented each time the state is updated
4. **Lineage**: A unique ID for the state to distinguish it from others
5. **Outputs**: Values exported from the root module
6. **Resources**: Details of managed resources

Example state structure (simplified):
```json
{
  "version": 4,
  "terraform_version": "1.3.0",
  "serial": 5,
  "lineage": "3f8a5c4e-2445-8548-7b4e-7a5e5e1f2a3b",
  "outputs": {
    "instance_ip": {
      "value": "10.0.1.10",
      "type": "string"
    }
  },
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "web",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0c55b159cbfafe1f0",
            "instance_type": "t2.micro",
            "id": "i-0123456789abcdef0"
            // other attributes...
          }
        }
      ]
    }
  ]
}
```

## Remote Backend Configuration

### What are Remote Backends?

Remote backends store Terraform state in a remote, shared storage location rather than on the local filesystem. This enables:
- Team collaboration
- State locking
- Secret management
- Remote operations (in some backends)

### Common Backend Types

1. **S3**: AWS S3 bucket with optional DynamoDB for locking
2. **Azure Storage**: Azure Blob Storage with locking
3. **Google Cloud Storage**: GCS bucket for state storage
4. **Terraform Cloud/Enterprise**: HashiCorp's managed state service
5. **Consul**: HashiCorp's service discovery and configuration tool
6. **PostgreSQL**: Database backend for state
7. **HTTP**: Custom HTTP endpoints for state management

### Configuring an AWS S3 Backend

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Configuring an Azure Storage Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-storage-rg"
    storage_account_name = "terraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

### Configuring a Terraform Cloud Backend

```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "my-app-prod"
    }
  }
}
```

## Backend Authentication

### AWS S3 Backend Authentication

Options for AWS authentication:

1. **Static credentials in configuration** (not recommended for production):
   ```hcl
   terraform {
     backend "s3" {
       access_key = "AKIAIOSFODNN7EXAMPLE"
       secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
       # other settings...
     }
   }
   ```

2. **Environment variables**:
   ```bash
   export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
   export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
   export AWS_REGION="us-west-2"
   ```

3. **AWS profile**:
   ```hcl
   terraform {
     backend "s3" {
       profile = "terraform"
       # other settings...
     }
   }
   ```

4. **IAM instance profiles** (for EC2 instances)
5. **AWS IAM roles** (for ECS/EKS)

### Azure Storage Backend Authentication

Options for Azure authentication:

1. **Service Principal with Client Secret**:
   ```bash
   export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
   export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
   export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
   ```

2. **Managed Identity** (for Azure resources):
   ```bash
   export ARM_USE_MSI=true
   ```

3. **Azure CLI authentication**:
   - Use `az login` before running Terraform commands

### GCP Storage Backend Authentication

Options for GCP authentication:

1. **Service Account Key File**:
   ```hcl
   terraform {
     backend "gcs" {
       credentials = "/path/to/service-account-key.json"
       # other settings...
     }
   }
   ```

2. **Environment variable**:
   ```bash
   export GOOGLE_CREDENTIALS="/path/to/service-account-key.json"
   ```

3. **Application Default Credentials**:
   - Use `gcloud auth application-default login` before running Terraform

## State Locking

### Purpose of State Locking

State locking prevents multiple users or processes from modifying the state simultaneously, which could cause:
- State file corruption
- Lost updates
- Inconsistent infrastructure

### How Locking Works

1. When Terraform operations that modify state begin, Terraform tries to acquire a lock
2. If the lock is already held, Terraform waits or fails (depending on settings)
3. When the operation completes, Terraform releases the lock

### Backend-Specific Locking

Different backends implement locking differently:

1. **S3**: Uses DynamoDB table for locking
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "terraform-state"
       key            = "network/terraform.tfstate"
       region         = "us-west-2"
       dynamodb_table = "terraform-lock"  # For state locking
     }
   }
   ```

2. **Azure**: Uses blob leases for locking (built-in)
3. **Consul**: Uses Consul's key-value store for locks
4. **Terraform Cloud**: Has built-in locking mechanisms

### Managing Locks

In rare cases, you might need to manually manage locks:

1. **Skip locking** (use caution):
   ```bash
   terraform apply -lock=false
   ```

2. **Adjust lock timeout**:
   ```bash
   terraform apply -lock-timeout=10m
   ```

3. **Force unlock** (use only if lock is stuck):
   ```bash
   terraform force-unlock LOCK_ID
   ```

## State Management Best Practices

### 1. Use Remote Backends

Always use remote backends for team environments to:
- Enable collaboration
- Prevent conflicts
- Improve security with encryption
- Add state versioning

### 2. Isolate State by Environment

Separate state files for different environments:

```hcl
# For S3
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "dev/terraform.tfstate"  # For dev environment
    # Or "prod/terraform.tfstate" for production
  }
}

# For Terraform Cloud
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "my-app-dev"  # Or "my-app-prod" for production
    }
  }
}
```

### 3. Secure Your State

State files can contain sensitive data. Secure them by:
- Enabling encryption at rest
- Restricting access to the storage backend
- Using the `sensitive` flag for outputs

Example:
```hcl
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "app/terraform.tfstate"
    encrypt = true  # Enables server-side encryption
  }
}

# Mark sensitive outputs
output "database_password" {
  value     = aws_db_instance.db.password
  sensitive = true
}
```

### 4. Use State Workspaces for Isolation

Workspaces allow multiple state files in the same backend location:

```bash
# Create a new workspace
terraform workspace new dev

# List workspaces
terraform workspace list

# Select a workspace
terraform workspace select prod
```

In your configuration, reference the workspace:
```hcl
resource "aws_instance" "example" {
  count = terraform.workspace == "prod" ? 3 : 1
  
  tags = {
    Environment = terraform.workspace
  }
}
```

### 5. Back Up Your State

Regularly back up your state files:

1. **S3 Versioning**:
   ```hcl
   resource "aws_s3_bucket" "terraform_state" {
     bucket = "terraform-state"
     
     versioning {
       enabled = true
     }
   }
   ```

2. **State Snapshots**:
   ```bash
   terraform state pull > terraform-state-backup-$(date +%F).json
   ```

### 6. Use Consistent Naming

Adopt a naming convention for state files and storage locations:

```
<company>-<project>-<environment>
```

Examples:
- `acme-webshop-prod`
- `acme-webshop-dev`
- `acme-webshop-staging`

## Terraform State Commands

### Viewing and Manipulating State

1. **List Resources**:
   ```bash
   terraform state list
   ```

2. **Show Resource Details**:
   ```bash
   terraform state show aws_instance.web
   ```

3. **Move Resource Within State**:
   ```bash
   terraform state mv aws_instance.web aws_instance.web_server
   ```

4. **Remove Resource from State**:
   ```bash
   terraform state rm aws_instance.web
   ```

5. **Import Existing Resource to State**:
   ```bash
   terraform import aws_instance.imported i-1234567890abcdef0
   ```

### Managing State Files

1. **Pull Remote State to Local**:
   ```bash
   terraform state pull > terraform.tfstate.backup
   ```

2. **Push Local State to Remote**:
   ```bash
   terraform state push terraform.tfstate.backup
   ```

## Key Points for the Exam

1. Terraform state maps configuration to real infrastructure resources
2. Remote backends enable team collaboration and state locking
3. Different backend types include S3, Azure Storage, GCS, and Terraform Cloud
4. Backend authentication varies by provider but usually supports environment variables
5. State locking prevents concurrent modifications that could corrupt state
6. Separate state files should be used for different environments
7. Always secure state files as they may contain sensitive information
8. Workspaces provide another way to isolate state for different environments
9. Regularly back up state files to prevent data loss 