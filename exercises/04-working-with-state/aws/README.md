# Exercise 4: Working with State in Terraform (AWS)

## Objectives

In this exercise, you will learn how to:

1. Understand Terraform state and its importance
2. Work with local state files and their limitations
3. Configure and use remote state with AWS S3 and DynamoDB
4. Perform state operations (import, move, remove)
5. Lock state to prevent concurrent modifications

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Basic understanding of AWS services (S3, DynamoDB)

## Instructions

### Step 1: Understand Terraform State

Before starting, review the concept of Terraform state:
- State stores information about the infrastructure created by Terraform
- It maps real-world resources to the configuration
- It's used to track metadata and improve performance
- By default, state is stored locally in `terraform.tfstate`

### Step 2: Create an Infrastructure with Local State

1. Initialize the directory:
   ```bash
   mkdir terraform-local-state
   cd terraform-local-state
   ```

2. Create the following files:

   **main.tf**:
   ```hcl
   provider "aws" {
     region = "us-east-1"
   }
   
   resource "aws_vpc" "main" {
     cidr_block = "10.0.0.0/16"
     tags = {
       Name = "main-vpc"
     }
   }
   
   resource "aws_subnet" "public" {
     vpc_id            = aws_vpc.main.id
     cidr_block        = "10.0.1.0/24"
     availability_zone = "us-east-1a"
     tags = {
       Name = "public-subnet"
     }
   }
   ```

3. Initialize, plan, and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. Examine the local state file:
   ```bash
   cat terraform.tfstate
   ```

### Step 3: Set Up Remote State

1. Create a new directory:
   ```bash
   mkdir terraform-remote-state
   cd terraform-remote-state
   ```

2. Create the following files:

   **backend.tf**:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "YOUR_UNIQUE_BUCKET_NAME"
       key            = "terraform/state/remote-demo"
       region         = "us-east-1"
       dynamodb_table = "terraform-state-lock"
       encrypt        = true
     }
   }
   ```

   **s3-setup.tf**:
   ```hcl
   provider "aws" {
     region = "us-east-1"
   }
   
   resource "aws_s3_bucket" "terraform_state" {
     bucket = "YOUR_UNIQUE_BUCKET_NAME"
   
     lifecycle {
       prevent_destroy = true
     }
   }
   
   resource "aws_s3_bucket_versioning" "terraform_state" {
     bucket = aws_s3_bucket.terraform_state.id
     versioning_configuration {
       status = "Enabled"
     }
   }
   
   resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
     bucket = aws_s3_bucket.terraform_state.id
   
     rule {
       apply_server_side_encryption_by_default {
         sse_algorithm = "AES256"
       }
     }
   }
   
   resource "aws_dynamodb_table" "terraform_locks" {
     name         = "terraform-state-lock"
     billing_mode = "PAY_PER_REQUEST"
     hash_key     = "LockID"
   
     attribute {
       name = "LockID"
       type = "S"
     }
   }
   ```

3. Initialize and apply to create the backend infrastructure:
   ```bash
   terraform init
   terraform apply
   ```

4. Comment out the S3 and DynamoDB resources (once created):
   ```hcl
   /* 
   resource "aws_s3_bucket" "terraform_state" {
     # Configuration...
   }
   # ... other backend resources
   */
   ```

5. Reinitialize with the remote backend:
   ```bash
   terraform init
   ```

### Step 4: Create Resources with Remote State

1. Create a main.tf file with the same VPC and subnet from Step 2.

2. Apply the configuration:
   ```bash
   terraform plan
   terraform apply
   ```

3. Verify the state is stored in S3:
   ```bash
   aws s3 ls s3://YOUR_UNIQUE_BUCKET_NAME/terraform/state/
   ```

### Step 5: State Operations

1. **Import Resources**: Import an existing resource (that was manually created) into Terraform state.

   Create a security group in the AWS console manually, then import it:
   ```hcl
   # Add to main.tf
   resource "aws_security_group" "imported" {
     name        = "manually-created-sg"
     description = "Security group created manually"
     vpc_id      = aws_vpc.main.id
     
     # Add rules to match the existing security group
   }
   ```

   ```bash
   terraform import aws_security_group.imported sg-XXXXX
   ```

2. **Move Resources**: Change the name of a resource in your configuration.

   ```bash
   terraform state mv aws_subnet.public aws_subnet.public_subnet
   ```

   Update the configuration to match the new name.

3. **Remove Resources**: Remove a resource from state without destroying it.

   ```bash
   terraform state rm aws_subnet.public_subnet
   ```

### Step 6: State Locking

1. Observe how the DynamoDB table works for locking:
   - Start a long-running apply in one terminal
   - Try to run another apply in a second terminal before the first one completes
   - Notice the lock error message

2. Check the DynamoDB table for lock information:
   ```bash
   aws dynamodb get-item \
     --table-name terraform-state-lock \
     --key '{"LockID": {"S": "YOUR_UNIQUE_BUCKET_NAME/terraform/state/remote-demo"}}'
   ```

### Step 7: Clean Up

```bash
terraform destroy
```

Remember to delete your S3 bucket and DynamoDB table if they're no longer needed.

## Challenges

1. **Workspaces**: Use Terraform workspaces to manage multiple environments (dev, test, prod) with the same configuration.

2. **State Migration**: Migrate state from local to remote and back.

3. **Data Handling**: Use the terraform_remote_state data source to read outputs from another Terraform configuration.

4. **Partial Configurations**: Work with partial backend configurations using `-backend-config` flags.

5. **Force Unlock**: Experiment with the `terraform force-unlock` command after a failed apply.

## Resources

- [Terraform State Documentation](https://www.terraform.io/docs/language/state/index.html)
- [Remote State Documentation](https://www.terraform.io/docs/language/state/remote.html)
- [S3 Backend Documentation](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [State Commands](https://www.terraform.io/docs/cli/commands/state/index.html)
- [Import Documentation](https://www.terraform.io/docs/cli/import/index.html) 