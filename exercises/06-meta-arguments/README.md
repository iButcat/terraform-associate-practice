# Exercise 6: Resource Meta-Arguments in Terraform

## Objective
Learn how to use Terraform resource meta-arguments, including count, for_each, depends_on, lifecycle, and provider configurations.

## Prerequisites
- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions
- Basic understanding of Terraform configuration from previous exercises

## Step-by-Step Instructions

### Step 1: Create the Configuration Files

Create a new directory for this exercise and navigate to it:

```bash
mkdir -p terraform-exercises/06-meta-arguments
cd terraform-exercises/06-meta-arguments
```

### Step 2: Using the `count` Meta-Argument

1. Create `count.tf`:

```hcl
# Create multiple EC2 instances using count
resource "aws_instance" "web" {
  count = 3
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# Create multiple IAM users using count
resource "aws_iam_user" "developers" {
  count = length(var.developer_names)
  
  name = var.developer_names[count.index]
  
  tags = {
    Role = "Developer"
  }
}

variable "developer_names" {
  type    = list(string)
  default = ["dev1", "dev2", "dev3"]
}
```

### Step 3: Using the `for_each` Meta-Argument

1. Create `for_each.tf`:

```hcl
# Create multiple S3 buckets using for_each with a set
resource "aws_s3_bucket" "data" {
  for_each = toset(var.bucket_names)
  
  bucket = each.key
  
  tags = {
    Environment = "dev"
    Name        = each.key
  }
}

# Create multiple IAM users using for_each with a map
resource "aws_iam_user" "operators" {
  for_each = var.operator_roles
  
  name = each.key
  
  tags = {
    Role = each.value.role
    Team = each.value.team
  }
}

variable "bucket_names" {
  type    = list(string)
  default = ["data-bucket-1", "data-bucket-2", "data-bucket-3"]
}

variable "operator_roles" {
  type = map(object({
    role = string
    team = string
  }))
  default = {
    "op1" = {
      role = "SysAdmin"
      team = "Infrastructure"
    },
    "op2" = {
      role = "DevOps"
      team = "Platform"
    }
  }
}
```

### Step 4: Using the `depends_on` Meta-Argument

1. Create `depends_on.tf`:

```hcl
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "main-vpc"
  }
}

# Create a subnet that depends on the VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "main-subnet"
  }
}

# Create an EC2 instance that explicitly depends on both VPC and subnet
resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  
  depends_on = [
    aws_vpc.main,
    aws_subnet.main
  ]
  
  tags = {
    Name = "app-server"
  }
}
```

### Step 5: Using the `lifecycle` Meta-Argument

1. Create `lifecycle.tf`:

```hcl
# Create an RDS instance with lifecycle rules
resource "aws_db_instance" "main" {
  identifier           = "example"
  engine              = "postgres"
  engine_version      = "13.7"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  
  db_name  = "example"
  username = "admin"
  password = "example-password"
  
  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }
}

# Create an S3 bucket with lifecycle rules
resource "aws_s3_bucket" "logs" {
  bucket = "example-logs"
  
  # Create new resource before destroying old one
  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name = "logs-bucket"
  }
}

# Create a security group with ignored changes
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Web server security group"
  
  # Ignore changes to tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### Step 6: Using Provider Configuration

1. Create `provider.tf`:

```hcl
# Configure the default provider
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = "dev"
      Project     = "learning"
    }
  }
}

# Configure an additional provider for a different region
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Create a resource using the default provider
resource "aws_s3_bucket" "east" {
  bucket = "example-east"
}

# Create a resource using the alternate provider
resource "aws_s3_bucket" "west" {
  provider = aws.west
  bucket   = "example-west"
}
```

### Step 7: Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### Step 8: Test Different Meta-Arguments

1. Modify the count value and observe changes
2. Add/remove items from for_each maps/sets
3. Test dependency order with depends_on
4. Try to destroy protected resources
5. Observe behavior of create_before_destroy

### Step 9: Clean Up

```bash
terraform destroy
```

## Additional Challenges

1. Use count with dynamic block generation
2. Implement complex for_each with nested maps
3. Create cross-region resource dependencies
4. Use lifecycle rules with provisioners
5. Implement provider configurations for multiple AWS accounts

## Solution

See the [solution](./solution) directory for a complete working example.

## Key Learnings

- Using count for simple resource repetition
- Using for_each for complex resource generation
- Managing resource dependencies with depends_on
- Controlling resource lifecycle behavior
- Working with multiple provider configurations
- Understanding when to use each meta-argument
- Best practices for resource management 