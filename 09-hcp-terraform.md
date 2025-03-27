# HCP Terraform Capabilities

HashiCorp Cloud Platform (HCP) Terraform, formerly known as Terraform Cloud, provides enhanced capabilities for managing Terraform infrastructure at scale. Understanding these capabilities is important for the certification exam.

## Overview of HCP Terraform

HCP Terraform is a cloud-based service from HashiCorp that offers:
- Remote state management
- Collaborative workflows
- Policy enforcement
- Private module registry
- CI/CD integrations
- Governance features
- API and automation capabilities

HCP Terraform comes in three tiers:
1. **Free Tier** (limited features for individuals/small teams)
2. **Team & Governance Tier** (team collaboration and basic governance)
3. **Business Tier** (advanced governance, SSO, audit, etc.)

## Remote State Management in HCP Terraform

### Configuring HCP Terraform as a Backend

```hcl
terraform {
  cloud {
    organization = "my-organization"
    workspaces {
      name = "my-app-prod"
    }
  }
}
```

### Benefits of HCP Terraform State Management

1. **Security**
   - Encryption at rest and in transit
   - Access controls
   - No local state files

2. **Collaboration**
   - Centralized state
   - Automatic state locking
   - State history and versioning

3. **Reliability**
   - Hosted and managed by HashiCorp
   - Highly available
   - Regular backups

### Workspace Types

HCP Terraform supports two types of workspaces:

1. **CLI-driven workflows**
   - Terraform commands executed locally
   - State stored in HCP Terraform
   - Integration with version control optional

2. **Version Control System (VCS) driven workflows**
   - Connected to a Git repository
   - Automatically triggered on commits
   - Terraform commands executed remotely
   - "Infrastructure as Code" approach

## Execution Models

### Local Execution

In local execution:
- Terraform commands run on your local machine
- State is pushed to HCP Terraform
- Resources are created from your machine

Configuration:
```hcl
terraform {
  cloud {
    organization = "my-organization"
    workspaces {
      name = "my-app-prod"
    }
    execution_mode = "local"
  }
}
```

### Remote Execution

In remote execution:
- Terraform commands run on HCP Terraform servers
- No local access or credentials needed
- Consistent execution environment

Configuration:
```hcl
terraform {
  cloud {
    organization = "my-organization"
    workspaces {
      name = "my-app-prod"
    }
    execution_mode = "remote"
  }
}
```

Benefits of remote execution:
- Consistent environment
- Secure credential management
- Parallel operations
- Detailed logging

## Team Collaboration Features

### Workspace Management

HCP Terraform workspaces offer:
- Environment-specific settings
- Variable management (including sensitive values)
- Run triggers between workspaces
- Access controls

### User Management and Permissions

HCP Terraform provides:
- Organization-level roles
- Workspace-level permissions
- Team management
- SSO integration (Business tier)

Common roles and permissions:
- Organization Owner
- Organization Member
- Workspace Admin
- Workspace Write
- Workspace Read

### Collaborative Workflow

The typical HCP Terraform workflow:

1. **Write** code and commit to VCS
2. **Plan** automatically triggered in HCP Terraform
3. **Review** plan with team members
4. **Apply** changes after approval
5. **Monitor** the infrastructure state

## Sentinel Policies for Governance

### What is Sentinel?

Sentinel is HashiCorp's policy as code framework that enables:
- Fine-grained, logic-based policy decisions
- Governance across all HashiCorp products
- Enforcement of compliance and security standards

### How Sentinel Works with HCP Terraform

1. Policies are written in Sentinel language
2. Policies are applied to workspaces
3. Policies are checked during plan phase
4. Policies can allow, deny, or require additional approval

### Example Sentinel Policy

```hcl
# Only allow specific instance types
import "tfplan"

allowed_types = [
  "t3.micro",
  "t3.small",
  "t3.medium",
]

ec2_instances = filter tfplan.resource_changes as _, rc {
  rc.type is "aws_instance" and
  (rc.change.actions contains "create" or rc.change.actions contains "update")
}

instance_type_allowed = rule {
  all ec2_instances as _, instance {
    instance.change.after.instance_type in allowed_types
  }
}

main = rule {
  instance_type_allowed
}
```

### Sentinel Policy Types

HCP Terraform supports three policy enforcement levels:

1. **Advisory**: Issues warnings but allows operations to proceed
2. **Soft Mandatory**: Requires an override from authorized users
3. **Hard Mandatory**: Cannot be overridden

## Private Module Registry

### Purpose and Benefits

The private module registry provides:
- Centralized repository for reusable modules
- Version control of modules
- Documentation generation
- Access controls

### Publishing a Module

To publish a module:

1. Create a Git repository following the naming convention:
   - `terraform-<PROVIDER>-<MODULE_NAME>`

2. Add required files:
   - `main.tf`, `variables.tf`, `outputs.tf`, etc.
   - `README.md` (for documentation)

3. Release a version with semantic versioning

4. Connect the repository to HCP Terraform

### Using Private Registry Modules

```hcl
module "vpc" {
  source  = "app.terraform.io/my-organization/vpc/aws"
  version = "1.0.0"
  
  name = "production-vpc"
  cidr = "10.0.0.0/16"
}
```

## Cost Estimation and Capacity Planning

### Cost Estimation Features

HCP Terraform provides cost estimation for:
- AWS
- Azure
- Google Cloud
- Oracle Cloud Infrastructure

Capabilities include:
- Pre-apply cost estimates
- Cost comparisons between runs
- Monthly projections

### Integrating Cost Estimation

Cost estimation is automatically enabled for supported providers and can be:
- Viewed in the UI during planning
- Used in approval workflows
- Shared with stakeholders

## HCP Terraform API and Automation

### API Capabilities

HCP Terraform offers a comprehensive API for:
- Workspace management
- Run management
- Variable management
- State management
- User/team management

### Common API Use Cases

1. **CI/CD Integration**:
   - Trigger runs from external systems
   - Extract outputs for downstream processes

2. **Workspace Automation**:
   - Create workspaces programmatically
   - Manage variables across workspaces

3. **Reporting**:
   - Collect state data for compliance
   - Generate infrastructure reports

### Authentication

API authentication uses token-based authentication:
- Organization tokens
- Team tokens
- User tokens

## CI/CD Integration

### VCS Integration

HCP Terraform connects with:
- GitHub
- GitLab
- Bitbucket
- Azure DevOps

Features:
- Automatic run triggering on commit
- Plan display in pull requests
- Apply on merge

### Other CI/CD Tools

Integration with other CI/CD systems:
- Jenkins
- CircleCI
- GitHub Actions
- Others via API

Example GitHub Actions workflow:
```yaml
name: "Terraform"

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve
```

## Key Differences: HCP Terraform vs. Terraform Community Edition

| Feature | HCP Terraform | Terraform Community Edition |
|---------|--------------|--------------------------|
| State Management | Remote, secure, versioned | Local by default, manual remote backend config required |
| Execution | Local or remote | Local only |
| Collaboration | Built-in | Manual, requires external tools |
| Private Registry | Included | Not available |
| Policy Enforcement | Sentinel available | Not available |
| Cost Estimation | Included | Not available |
| Approval Workflow | Built-in | Not available |
| API | Full platform API | Limited state operations |
| User Management | Organizations, teams, roles | No built-in user management |
| VCS Integration | Automatic | Manual |

## Key Points for the Exam

1. HCP Terraform offers remote state management with enhanced security and collaboration
2. Workspaces in HCP Terraform organize and separate environments and teams
3. HCP Terraform supports both local and remote execution models
4. Sentinel enables policy as code for governance and compliance
5. Private module registry provides a secure, centralized place for reusable modules
6. Cost estimation helps predict infrastructure spending before applying changes
7. HCP Terraform offers extensive APIs for automation and integration
8. VCS integration enables GitOps workflows with automatic planning and applying
9. HCP Terraform comes in Free, Team & Governance, and Business tiers with increasing capabilities 