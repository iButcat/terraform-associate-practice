# Read and Write Terraform Configuration

Understanding how to read and write Terraform configuration is essential for effectively managing infrastructure. This section covers the key aspects of Terraform's configuration language.

## Variables and Outputs

### Input Variables

Input variables allow you to parameterize your Terraform configurations:

```hcl
# Basic variable declaration
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

# Variable with validation
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = can(regex("^t[23]\\.", var.instance_type))
    error_message = "Instance type must be t2.* or t3.* series."
  }
}

# Complex type variables
variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block = string
    subnet_count = number
    enable_vpn_gateway = bool
    subnet_tags = map(string)
  })
  
  default = {
    cidr_block = "10.0.0.0/16"
    subnet_count = 3
    enable_vpn_gateway = false
    subnet_tags = {
      Terraform = "true"
      Environment = "dev"
    }
  }
}
```

### Variable Types

Terraform supports these variable types:

1. **Primitive Types**:
   - `string`: Sequence of characters
   - `number`: Numeric values
   - `bool`: Boolean (true/false)

2. **Complex Types**:
   - `list(type)`: Ordered collection of one type
   - `set(type)`: Unordered collection of unique values
   - `map(type)`: Collection of key-value pairs
   - `object({attr = type, ...})`: Collection of named attributes
   - `tuple([type, ...])`: Sequence of elements with different types

### Using Variables

Reference variables with the `var.` prefix:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = var.tags
}
```

### Setting Variable Values

Variables can be set in multiple ways, with the following precedence (highest to lowest):

1. **Command-line flags**:
   ```bash
   terraform apply -var="region=us-east-1" -var="instance_count=3"
   ```

2. **Variable definition files**:
   ```bash
   terraform apply -var-file="prod.tfvars"
   ```
   
   Example `prod.tfvars` file:
   ```hcl
   region         = "us-east-1"
   instance_count = 5
   tags           = {
     Environment = "production"
     Owner       = "ops-team"
   }
   ```

3. **Environment variables** (prefixed with `TF_VAR_`):
   ```bash
   export TF_VAR_region="us-east-1"
   export TF_VAR_instance_count=3
   terraform apply
   ```

4. **terraform.tfvars** or **terraform.tfvars.json** files
5. ***.auto.tfvars** or ***.auto.tfvars.json** files
6. **Default values** in variable declarations

### Sensitive Variables

Mark variables containing sensitive data:

```hcl
variable "database_password" {
  description = "Password for database"
  type        = string
  sensitive   = true
}
```

Sensitive values are:
- Redacted in console output
- Still stored in state file (so state should be secured)
- Can be passed to providers and modules

### Output Values

Outputs expose selected values from your configuration:

```hcl
output "instance_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

# Complex output
output "vpc_info" {
  description = "VPC information"
  value = {
    id         = aws_vpc.main.id
    cidr_block = aws_vpc.main.cidr_block
    subnet_ids = aws_subnet.main[*].id
  }
}

# Sensitive output
output "db_connection_string" {
  description = "Database connection string"
  value       = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.db.endpoint}/postgres"
  sensitive   = true
}
```

Access outputs after applying:
```bash
terraform output
terraform output instance_ip
terraform output -json  # Get all outputs in JSON format
```

## Data Sources

Data sources allow Terraform to fetch and use information defined outside your configuration:

```hcl
# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use the data source
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
}

# Query existing resources
data "aws_vpc" "default" {
  default = true
}

# Use in other resources
resource "aws_security_group" "example" {
  name   = "example"
  vpc_id = data.aws_vpc.default.id
}
```

## Understanding Resource Attributes and Meta-Arguments

### Resource Attributes

Each resource type has its own set of attributes defined by the provider:

```hcl
resource "aws_instance" "web" {
  # Required attributes
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
  
  # Optional attributes
  associate_public_ip_address = true
  key_name                    = "my-key"
  
  # Nested block attributes
  ebs_block_device {
    device_name = "/dev/sdh"
    volume_size = 100
    volume_type = "gp3"
    encrypted   = true
  }
  
  # Tags attribute (map)
  tags = {
    Name        = "WebServer"
    Environment = "Production"
  }
}
```

### Resource Meta-Arguments

Meta-arguments apply to all resource types and control how Terraform manages the resource:

#### 1. `depends_on` - Explicit Dependencies

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  # Make sure the DB is created first
  depends_on = [
    aws_db_instance.main
  ]
}
```

#### 2. `count` - Create Multiple Resources

```hcl
resource "aws_instance" "web" {
  count = 3
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# Access elements with indexing
resource "aws_eip" "web" {
  count = 3
  
  instance = aws_instance.web[count.index].id
}
```

#### 3. `for_each` - Create Multiple Resources from a Map or Set

```hcl
# Using a map
resource "aws_instance" "web" {
  for_each = {
    web1 = "t2.micro"
    web2 = "t2.small"
    web3 = "t2.medium"
  }
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = each.value
  
  tags = {
    Name = each.key
  }
}

# Using a set
resource "aws_subnet" "example" {
  for_each = toset(["us-east-1a", "us-east-1b", "us-east-1c"])
  
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, index(["us-east-1a", "us-east-1b", "us-east-1c"], each.key))
}
```

#### 4. `lifecycle` - Resource Lifecycle Management

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [
      tags,
      security_groups,
    ]
  }
}
```

#### 5. `provider` - Multiple Provider Instances

```hcl
# Default provider
provider "aws" {
  region = "us-west-2"
}

# East region provider
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

# Use the default provider
resource "aws_instance" "west" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# Use the aliased provider
resource "aws_instance" "east" {
  provider      = aws.east
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
}
```

## Dynamic Blocks

Dynamic blocks allow you to create repeated nested blocks dynamically:

```hcl
variable "ingress_rules" {
  description = "Ingress rules for security group"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  
  default = [
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]
}

resource "aws_security_group" "web" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  
  # Dynamic ingress blocks
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  
  # Standard egress block
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Using Built-in Functions

Terraform provides many built-in functions for transforming and combining values:

### String Functions

```hcl
locals {
  # Format string
  server_name = format("web-%s-%03d", var.environment, var.instance_number)
  
  # Join elements with a delimiter
  tags_string = join(", ", values(var.tags))
  
  # Split a string into a list
  regions     = split(",", var.region_list_csv)
  
  # Replace substring
  sanitized_name = replace(var.name, "/[^a-zA-Z0-9-]/", "-")
  
  # Regex replace
  domain_parts = regex("^(?:https?://)?(?:www\\.)?([^/]+)(?:/.*)?$", var.website_url)
}
```

### Collection Functions

```hcl
locals {
  # Map transformation
  upper_tags = { for k, v in var.tags : k => upper(v) }
  
  # Filter a map
  production_tags = { for k, v in var.tags : k => v if v == "production" }
  
  # Convert list to map
  instances_map = { for i, id in aws_instance.web : "instance-${i}" => id.public_ip }
  
  # Merge maps
  all_tags = merge(
    var.common_tags,
    var.environment_tags,
    {
      "Created" = formatdate("YYYY-MM-DD", timestamp())
    }
  )
  
  # Get keys/values
  tag_keys = keys(var.tags)
  tag_values = values(var.tags)
  
  # Check if element exists
  has_production_tag = contains(values(var.tags), "production")
}
```

### Numeric Functions

```hcl
locals {
  # Math operations
  total_cost = sum([for size in var.instance_sizes : lookup(local.size_cost_map, size, 0)])
  
  # Min/max
  largest_instance = max(var.instance_sizes...)
  
  # Ceiling/floor
  instances_needed = ceil(var.user_count / 50)
}
```

### IP Network Functions

```hcl
locals {
  # Subnet calculation
  subnets = [
    cidrsubnet(var.vpc_cidr, 8, 0),  # 10.0.0.0/24
    cidrsubnet(var.vpc_cidr, 8, 1),  # 10.0.1.0/24
    cidrsubnet(var.vpc_cidr, 8, 2)   # 10.0.2.0/24
  ]
  
  # Check if IP is in CIDR
  is_private = cidrcontains("10.0.0.0/8", var.ip_address)
}
```

## Local Values (locals)

Local values let you assign a name to an expression for reuse within a module:

```hcl
locals {
  # Simple values
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
    Owner       = "Infrastructure Team"
  }
  
  # Computed values
  is_production = var.environment == "prod"
  
  # Conditionals
  instance_type = local.is_production ? "t3.large" : "t3.small"
  
  # Complex expressions
  subnet_ids = flatten([
    aws_subnet.public[*].id,
    aws_subnet.private[*].id
  ])
  
  # Name transformation
  name_prefix = "${var.project_name}-${var.environment}"
}

# Using locals
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = local.instance_type
  
  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-web"
    }
  )
}
```

## Key Points for the Exam

1. Input variables parameterize configurations and can have constraints and validations
2. Sensitive variables and outputs are redacted in logs but still stored in state
3. Data sources retrieve information from providers or existing infrastructure
4. Resource meta-arguments like `count`, `for_each`, and `lifecycle` control resource behavior
5. Dynamic blocks generate repeated nested blocks based on collections
6. Built-in functions transform and manipulate values
7. Local values simplify complex expressions and reduce repetition
8. Variable values have a precedence order, with command-line flags having highest priority 