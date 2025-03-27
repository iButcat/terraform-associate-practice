# Terraform Modules

Modules are containers for multiple resources that are used together. They allow you to organize, encapsulate, and reuse Terraform code.

## Module Source Options

### Types of Module Sources

Terraform supports various module source types:

1. **Local Paths**
   - References modules in the local filesystem
   - Example: `source = "./modules/vpc"`
   - Best for modules that are part of your main codebase

2. **Terraform Registry**
   - Public registry at registry.terraform.io
   - Example: `source = "terraform-aws-modules/vpc/aws"`
   - Verified modules available from HashiCorp and partners

3. **GitHub, GitLab, Bitbucket**
   - Repositories containing Terraform configurations
   - Example: `source = "github.com/username/repo//modules/vpc"`
   - Note the double slash (`//`) to specify a subdirectory

4. **HTTP URLs**
   - Modules from HTTP/HTTPS URLs
   - Example: `source = "https://example.com/vpc-module.zip"`
   - Archives are automatically extracted

5. **S3, GCS, other storage services**
   - Modules stored in object storage buckets
   - Example: `source = "s3::https://s3-eu-west-1.amazonaws.com/bucket-name/vpc-module.zip"`

6. **Terraform Enterprise/Cloud Private Registry**
   - Private modules from your organization
   - Example: `source = "app.terraform.io/example-corp/vpc/aws"`

### Using the Terraform Registry

The Terraform Registry is the primary source for publicly available modules:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  # other arguments...
}
```

To find modules:
1. Visit registry.terraform.io
2. Search for modules by provider or functionality
3. Check verification status, downloads, and documentation
4. Review input variables, outputs, and examples

### Private Registry Modules

For enterprise users with Terraform Cloud or Enterprise:

```hcl
module "vpc" {
  source  = "app.terraform.io/my-organization/vpc/aws"
  version = "1.0.0"
}
```

## Interacting with Module Inputs and Outputs

### Module Input Variables

Input variables allow customization of modules:

```hcl
# In modules/web-server/variables.tf
variable "server_name" {
  description = "Name of the web server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
```

### Passing Values to Module Inputs

When calling a module, provide values for input variables:

```hcl
module "web_server" {
  source = "./modules/web-server"
  
  server_name  = "production-web"
  instance_type = "t3.medium"
  vpc_id       = aws_vpc.main.id
}
```

### Module Outputs

Outputs make module data available to the parent module:

```hcl
# In modules/web-server/outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}
```

### Accessing Module Outputs

Access module outputs using the `module.<MODULE_NAME>.<OUTPUT_NAME>` syntax:

```hcl
resource "aws_route53_record" "web" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.example.com"
  type    = "A"
  ttl     = 300
  records = [module.web_server.public_ip]
}

output "web_server_info" {
  value = {
    id       = module.web_server.instance_id
    public_ip = module.web_server.public_ip
  }
}
```

## Variable Scope in Modules

### Understanding Module Variable Scope

1. **Root Module Scope**
   - Variables and outputs defined in the root module
   - Accessible throughout the root module configuration

2. **Child Module Scope**
   - Variables and outputs defined within a module
   - Only accessible within that module
   - Outputs exposed to parent module

3. **Isolation Between Modules**
   - Sibling modules cannot directly access each other's variables
   - Communication between modules must happen via the parent module

### Scope Examples

```hcl
# Root module
variable "environment" {
  type = string
  default = "dev"
}

module "network" {
  source = "./modules/network"
  environment = var.environment  # Pass down from root
}

module "app" {
  source = "./modules/app"
  environment = var.environment  # Pass down from root
  vpc_id = module.network.vpc_id  # Pass output from one module to another
}
```

Inside the network module:
```hcl
# modules/network/main.tf
variable "environment" {
  type = string
}

# This module can't access variables from the app module directly
# It only knows about its own inputs

output "vpc_id" {
  value = aws_vpc.this.id
}
```

### Passing Data Between Modules

Data is passed between modules through the parent module:

1. Module A outputs a value
2. Parent module references that output
3. Parent module passes the value to Module B as an input

```hcl
# Module A outputs a value
output "subnet_ids" {
  value = aws_subnet.public[*].id
}

# Parent module
module "networking" {
  source = "./modules/networking"
}

module "application" {
  source = "./modules/application"
  
  # Pass Module A's output to Module B
  subnet_ids = module.networking.subnet_ids
}
```

## Setting Module Versions

### Importance of Module Versioning

Module versioning ensures:
- Consistent, reproducible infrastructure
- Controlled updates
- Compatibility between modules
- Safe testing of changes

### Version Constraint Syntax

Specify versions using the same constraint syntax as for providers:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"  # Exact version
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"  # Any 3.x version
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = ">= 3.0, < 4.0.0"  # Between 3.0.0 and 4.0.0
}
```

### Version Constraints Best Practices

1. **For Production**
   - Use exact versions (`version = "3.14.0"`) for stability
   - Update versions deliberately with appropriate testing

2. **For Development**
   - Use flexible constraints (`version = "~> 3.0"`) for latest patches
   - Test regularly with newer versions

3. **For Modules You Control**
   - Follow semantic versioning (SemVer) principles
   - Major version: Breaking changes
   - Minor version: New features, backward compatible
   - Patch version: Bug fixes

### Updating Module Versions

To update module versions:

```bash
# Check for available updates
terraform init -upgrade

# Or, modify version constraints in your code:
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.15.0"  # Updated from 3.14.0
}
```

## Creating Reusable Modules

### Module Structure Best Practices

A well-structured module typically includes:

```
modules/vpc/
├── main.tf       # Main resources
├── variables.tf  # Input variables
├── outputs.tf    # Output values
├── versions.tf   # Required providers and versions
└── README.md     # Documentation
```

### Input Variable Validation

Use validation rules to ensure proper module usage:

```hcl
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
  
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Allowed values for instance_type are t3.micro, t3.small, or t3.medium."
  }
}
```

### Module Composition

Complex infrastructure can be built by composing modules:

```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}

module "database" {
  source = "./modules/database"
  vpc_id = module.vpc.vpc_id
  security_group_id = module.security_groups.db_security_group_id
  subnet_ids = module.vpc.private_subnet_ids
}

module "application" {
  source = "./modules/application"
  vpc_id = module.vpc.vpc_id
  security_group_id = module.security_groups.app_security_group_id
  subnet_ids = module.vpc.public_subnet_ids
  db_endpoint = module.database.endpoint
}
```

## Key Points for the Exam

1. Modules help organize Terraform code into reusable components
2. The Terraform Registry is the official source for public modules
3. Module sources can be local paths, Git repositories, HTTP URLs, or cloud storage
4. Module inputs allow customization via variables
5. Module outputs expose data to the parent module
6. Variables are scoped to their module; sibling modules cannot access each other's variables directly
7. Specify module versions to ensure consistency and controlled updates
8. Follow semantic versioning for your own modules
9. Well-structured modules include main.tf, variables.tf, outputs.tf, and README.md 