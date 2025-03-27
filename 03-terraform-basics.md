# Terraform Basics

## Installing and Versioning Terraform Providers

### What are Terraform Providers?

Providers are plugins that Terraform uses to interact with cloud providers, SaaS providers, or other APIs. Providers define and manage resources for their respective platforms.

### Provider Installation

Terraform automatically installs providers during the `terraform init` process. Installation sources include:

1. **Terraform Registry** (default source)
2. **Private registry** (for enterprise environments)
3. **Local filesystem** (for custom or offline use)

### Provider Versioning

You can specify provider versions in your configuration to ensure consistency:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16" # Compatible with 4.16.x but not 5.x
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0, < 4.0.0" # Between 3.0.0 and 4.0.0
    }
  }
  
  required_version = ">= 1.2.0" # Minimum Terraform version required
}
```

### Version Constraints

Common version constraint operators:

- `=`: Exact version match
- `!=`: Not equal to version
- `>`, `>=`, `<`, `<=`: Version comparison
- `~>`: Allows only the rightmost version component to increment

Examples:
- `~> 1.0.0`: Allows 1.0.1, 1.0.9, but not 1.1.0
- `~> 1.0`: Allows 1.1, 1.9, but not 2.0
- `>= 1.0, <= 2.0`: Allows any version between 1.0 and 2.0 inclusive

### Provider Dependency Lock File

The `.terraform.lock.hcl` file locks provider versions for consistent runs:
- Created/updated during `terraform init`
- Should be committed to version control
- Can be updated with `terraform init -upgrade`

## Terraform's Plugin-Based Architecture

### How Terraform's Architecture Works

Terraform uses a plugin-based architecture that consists of:

1. **Core**: The main Terraform binary that:
   - Parses configuration
   - Builds resource graph
   - Executes plans
   - Manages state

2. **Providers**: Plugins that:
   - Define resources and data sources
   - Handle API interactions
   - Translate Terraform configuration into API calls
   - Convert API responses to Terraform state

3. **Provisioners**: Plugins that:
   - Execute actions on resources after creation
   - Configure resources that don't have API support

### Provider Plugin Interactions

1. **Discovery**: During `terraform init`, Terraform:
   - Analyzes configuration to determine required providers
   - Downloads provider plugins from registry or local path
   - Verifies checksums and installs plugins

2. **Protocol**: Terraform communicates with provider plugins via:
   - gRPC for recent providers
   - JSON-RPC for legacy providers

3. **Lifecycle**: Terraform manages provider plugin lifecycle:
   - Starts plugin processes as needed
   - Maintains connection throughout operations
   - Terminates plugins when operations complete

## Writing Terraform Configuration with Multiple Providers

### Basic Multi-Provider Configuration

```hcl
# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
  profile = "production"
}

# Configure the Azure provider
provider "azurerm" {
  features {}
  subscription_id = "12345678-1234-1234-1234-123456789012"
}

# AWS resource
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
  
  tags = {
    Environment = "Production"
  }
}

# Azure resource
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
```

### Provider Aliases

Provider aliases allow using the same provider with different configurations:

```hcl
# Default AWS provider (us-west-2)
provider "aws" {
  region = "us-west-2"
}

# AWS provider for East region
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

# Resource using default provider (us-west-2)
resource "aws_instance" "west_app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

# Resource using aliased provider (us-east-1)
resource "aws_instance" "east_app" {
  provider      = aws.east
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t2.micro"
}
```

### Module Provider Configuration

When using modules with multiple providers:

```hcl
# Root module configuration
provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

# Module using providers
module "app" {
  source = "./modules/app"
  
  providers = {
    aws        = aws
    aws.east   = aws.east
  }
}
```

Inside the module:
```hcl
# Inside modules/app/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
      configuration_aliases = [ aws.east ]
    }
  }
}

resource "aws_instance" "app" {
  # Uses default aws provider
}

resource "aws_instance" "east_app" {
  provider = aws.east
  # Uses east region provider
}
```

## How Terraform Finds and Fetches Providers

### Provider Search Path

Terraform finds providers in this order:

1. **Implicit local mirror**: Local filesystem (`terraform.d/plugins` or `.terraform/plugins`)
2. **Explicit path**: Provider configurations with explicit path
3. **Terraform Registry**: Default registry at registry.terraform.io
4. **Alternative registries**: Custom registry specified in provider source

### Provider Installation Process

During `terraform init`, Terraform:

1. Analyzes configuration for required providers
2. Checks for existing providers in `.terraform/providers`
3. If not found:
   - Determines required provider versions
   - Downloads plugins from appropriate sources
   - Verifies checksums of downloaded plugins
   - Installs plugins to `.terraform/providers`

### Provider Source Addresses

Provider source format: `[hostname]/[namespace]/[type]`

Examples:
- `hashicorp/aws`: Official AWS provider (hostname defaults to registry.terraform.io)
- `registry.example.com/company/custom`: Custom provider from private registry

### Registry API Interactions

When fetching from Terraform Registry:
1. Queries registry API for available versions
2. Selects appropriate version based on constraints
3. Downloads provider binary specific to OS/architecture
4. Verifies cryptographic signature

## Key Points for the Exam

1. Terraform uses providers to interact with various infrastructure platforms
2. Provider versions can be constrained for consistency
3. The `.terraform.lock.hcl` file locks provider versions and should be committed to version control
4. Terraform's architecture separates core functionality from provider-specific logic
5. Multiple providers can be used in the same configuration
6. Provider aliases allow using the same provider with different configurations
7. During `terraform init`, Terraform downloads required providers from the registry or other sources 