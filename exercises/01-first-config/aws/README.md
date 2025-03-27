# Exercise 1: Your First Terraform Configuration (AWS)

## Objective

Learn how to create a basic Terraform configuration to deploy AWS infrastructure. This exercise will help you understand the core Terraform workflow with AWS resources.

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- AWS CLI configured OR AWS access keys available

## AWS Authentication

You have two options for AWS authentication:

1. **AWS CLI Configuration**:
   - Install and configure the AWS CLI using `aws configure`
   - Terraform will automatically use these credentials

2. **Explicit Credentials in Terraform**:
   - Set environment variables:
     ```bash
     export AWS_ACCESS_KEY_ID="your_access_key"
     export AWS_SECRET_ACCESS_KEY="your_secret_key"
     export AWS_REGION="us-east-1"
     ```
   - Or specify directly in the provider (not recommended for production):
     ```hcl
     provider "aws" {
       region     = "us-east-1"
       access_key = "your_access_key"
       secret_key = "your_secret_key"
     }
     ```

## Instructions

### Step 1: Create the Configuration Files

Create a new directory for this exercise and navigate to it:

```bash
mkdir -p terraform-exercises/01-first-config
cd terraform-exercises/01-first-config
```

Create the following files:

1. `main.tf` - Main configuration file

```hcl
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
    Environment = "Learning"
    CreatedBy = "Terraform"
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "main-subnet"
  }
}

# Create a security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
```

2. `outputs.tf` - Define outputs

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.allow_ssh.id
}
```

3. `versions.tf` - Define provider versions

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  required_version = ">= 1.0.0"
}
```

### Step 2: Initialize the Working Directory

Run the following command to initialize your working directory:

```bash
terraform init
```

You should see output indicating that Terraform has been successfully initialized and the AWS provider has been installed.

### Step 3: Format and Validate the Configuration

Format your configuration files for consistency:

```bash
terraform fmt
```

Validate your configuration syntax:

```bash
terraform validate
```

You should see a message that the configuration is valid.

### Step 4: Create an Execution Plan

Generate an execution plan:

```bash
terraform plan
```

Review the execution plan to understand what Terraform will do. You should see that Terraform plans to create 3 resources:
- 1 VPC
- 1 subnet
- 1 security group

### Step 5: Apply the Configuration

Apply the configuration to create the resources:

```bash
terraform apply
```

When prompted, type `yes` to confirm. Terraform will proceed to create the resources in your AWS account.

After the apply is complete, you should see the output values for the VPC ID, subnet ID, and security group ID.

### Step 6: Verify the Created Resources

1. Log in to the AWS Management Console
2. Navigate to the VPC service
3. Confirm that the VPC, subnet, and security group have been created with the specified configuration

### Step 7: Examine the State File

Take a look at the state file that Terraform created:

```bash
terraform state list
```

This command shows all the resources in your state file.

To see details of a specific resource:

```bash
terraform state show aws_vpc.main
```

### Step 8: Destroy the Resources

When you're finished, destroy the resources to avoid any ongoing charges:

```bash
terraform destroy
```

When prompted, type `yes` to confirm.

## Additional Challenges

1. Modify your configuration to add a second subnet in a different availability zone
2. Add an Internet Gateway resource and attach it to your VPC
3. Create a Route Table and associate it with your subnets
4. Use variables to parameterize your configuration (e.g., for the CIDR blocks)

## Solution

The solution for this exercise is provided in the [solution](./solution) directory.

## Key Learnings

- How to configure the AWS provider
- How to create basic AWS networking resources
- How AWS resources refer to each other
- The core Terraform workflow with AWS
- How to view and interpret the state file 