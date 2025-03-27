# Web Module

This module creates EC2 instances for a web tier with an associated security group.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | `"dev"` | no |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| instance_count | Number of instances to create | `number` | `1` | no |
| ami_id | AMI ID to use for instances | `string` | `"ami-0c55b159cbfafe1f0"` | no |
| instance_type | Instance type | `string` | `"t2.micro"` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | The ID of the web security group |
| instance_ids | List of instance IDs |
| public_ips | List of public IP addresses |

## Example Usage

```hcl
module "web" {
  source = "./modules/web"
  
  environment    = "prod"
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.public_subnet_ids
  instance_count = 2
  instance_type  = "t2.small"
  
  tags = {
    Project = "my-project"
  }
}
``` 