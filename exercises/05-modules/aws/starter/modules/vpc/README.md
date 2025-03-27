# VPC Module

This module creates a VPC with public and private subnets in specified availability zones.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| environment | Environment name | `string` | `"dev"` | no |
| public_subnets | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` | no |
| private_subnets | CIDR blocks for private subnets | `list(string)` | `["10.0.3.0/24", "10.0.4.0/24"]` | no |
| availability_zones | Availability zones to use | `list(string)` | `["us-east-1a", "us-east-1b"]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr | The CIDR block of the VPC |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| public_route_table_id | ID of the public route table |
| private_route_table_id | ID of the private route table |

## Example Usage

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr          = "10.0.0.0/16"
  environment       = "prod"
  public_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  tags = {
    Project = "my-project"
  }
}
``` 