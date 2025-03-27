# Exercise 4: Working with Terraform State

## Objective
Learn how to work with Terraform state, including configuring remote backends, using state commands, and importing existing resources.

## Prerequisites
- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- Basic understanding of Terraform configuration from previous exercises
- S3 bucket for remote state storage (will be created in this exercise)

## Step-by-Step Instructions

### Step 1: Create the Configuration Files

Create a new directory for this exercise and navigate to it:

```bash
mkdir -p terraform-exercises/04-working-with-state
cd terraform-exercises/04-working-with-state
```

Create the following files:

1. `main.tf` - Main configuration file

```hcl
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket for remote state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-example-${random_id.bucket_suffix.hex}"
  
  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Generate random suffix for bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create a VPC for demonstration
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
    Environment = "Learning"
  }
}

# Create a subnet
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "main-subnet"
  }
}
```

2. `backend.tf` - Backend configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-example-1234"  # Replace with your bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}
```

3. `outputs.tf` - Define outputs

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main.id
}

output "state_bucket_name" {
  description = "The name of the S3 bucket used for state"
  value       = aws_s3_bucket.terraform_state.id
}
```

4. `versions.tf` - Define provider versions

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  
  required_version = ">= 1.0.0"
}
```

### Step 2: Initialize the Working Directory

```bash
terraform init
```

### Step 3: Apply the Configuration

```bash
terraform apply
```

When prompted, type `yes` to confirm.

### Step 4: Working with State Commands

1. **List Resources in State**
   ```bash
   terraform state list
   ```

2. **Show Resource Details**
   ```bash
   terraform state show aws_vpc.main
   ```

3. **Move Resources in State**
   ```bash
   # Rename a resource
   terraform state mv aws_subnet.main aws_subnet.public
   ```

4. **Remove Resource from State**
   ```bash
   # Remove a resource from state (but don't destroy it)
   terraform state rm aws_subnet.public
   ```

5. **Pull State**
   ```bash
   # Get current state
   terraform state pull > state_backup.tfstate
   ```

6. **Push State**
   ```bash
   # Restore state from backup
   terraform state push state_backup.tfstate
   ```

### Step 5: Importing Existing Resources

1. **Create a Resource Manually**
   - Go to AWS Console
   - Create a new security group
   - Note its ID

2. **Add Resource to Configuration**
   ```hcl
   resource "aws_security_group" "imported" {
     name        = "imported-sg"
     description = "Security group imported from AWS"
     vpc_id      = aws_vpc.main.id
   }
   ```

3. **Import the Resource**
   ```bash
   terraform import aws_security_group.imported sg-1234567890abcdef0
   ```

### Step 6: Working with Remote State

1. **Check State Location**
   ```bash
   terraform state list
   ```

2. **Verify State Locking**
   - Open another terminal
   - Try to run `terraform apply` in the same directory
   - Notice the state lock message

3. **Force Unlock State** (if needed)
   ```bash
   terraform force-unlock LOCK_ID
   ```

### Step 7: Clean Up

```bash
terraform destroy
```

## Additional Challenges

1. Configure a different backend (Azure Storage or GCS)
2. Set up state migration between backends
3. Create a custom state file format
4. Implement state file encryption
5. Set up state file backup automation

## Solution

See the [solution](./solution) directory for a complete working example.

## Key Learnings

- Remote state enables team collaboration and state locking
- State commands help manage and troubleshoot infrastructure
- Importing resources brings existing infrastructure under Terraform management
- State locking prevents concurrent modifications
- State backups are important for disaster recovery
- Different backend types offer various features and trade-offs
- State file contains sensitive information and should be secured 