# DB Module

This module creates an RDS database instance with an associated security group and subnet group.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name | `string` | `"dev"` | no |
| vpc_id | VPC ID | `string` | n/a | yes |
| subnet_ids | List of subnet IDs | `list(string)` | n/a | yes |
| allowed_security_group_ids | List of security group IDs that can access the database | `list(string)` | n/a | yes |
| database_name | Name of the database | `string` | `"appdb"` | no |
| username | Database username | `string` | `"admin"` | no |
| password | Database password | `string` | n/a | yes |
| instance_class | Database instance class | `string` | `"db.t2.micro"` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | The database endpoint |
| security_group_id | The ID of the database security group |
| db_instance_id | The ID of the database instance |

## Example Usage

```hcl
module "db" {
  source = "./modules/db"
  
  environment               = "prod"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  allowed_security_group_ids = [module.web.security_group_id]
  database_name             = "proddb"
  username                  = "admin"
  password                  = var.db_password
  instance_class            = "db.t2.small"
  
  tags = {
    Project = "my-project"
  }
} 