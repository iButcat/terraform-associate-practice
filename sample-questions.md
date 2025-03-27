# Sample Questions for Terraform Associate Certification

This document contains practice questions to help you prepare for the HashiCorp Terraform Associate Certification exam. Each question is presented with multiple choice answers and an explanation of the correct answer.

## Infrastructure as Code Concepts

### Question 1
What is Infrastructure as Code (IaC)?

A. A process where infrastructure is manually provisioned through a web console
B. A way to define infrastructure using code that can be versioned, shared, and reused
C. A tool specifically for AWS resource provisioning
D. A documentation method for describing infrastructure

**Answer: B**

*Explanation: Infrastructure as Code (IaC) is an approach that enables you to define and manage infrastructure using code that can be versioned, shared, and reused, rather than through manual processes or using a graphical user interface.*

### Question 2
Which of the following is NOT an advantage of Infrastructure as Code?

A. Consistency and standardization across deployments
B. Faster provisioning of infrastructure
C. Elimination of the need for security controls
D. Ability to version control infrastructure changes

**Answer: C**

*Explanation: Infrastructure as Code does not eliminate the need for security controls. In fact, security must still be carefully considered and implemented in IaC. The other options are valid advantages of using IaC.*

## Purpose of Terraform

### Question 3
Which of the following is a key benefit of Terraform over cloud-specific tools like AWS CloudFormation?

A. It can only be used with AWS
B. It's provider-agnostic and supports multiple cloud providers
C. It's faster since it's written in Go
D. It doesn't require any state management

**Answer: B**

*Explanation: A key benefit of Terraform is that it's provider-agnostic, meaning it can manage infrastructure across multiple cloud providers and services with the same tool and workflow. CloudFormation, by contrast, only works with AWS.*

### Question 4
What is the primary purpose of Terraform state?

A. To authenticate with cloud providers
B. To map the Terraform configuration to real-world resources
C. To encrypt sensitive data in the configuration
D. To speed up the initialization process

**Answer: B**

*Explanation: The primary purpose of Terraform state is to map resources defined in your configuration to the real-world resources they represent. State keeps track of metadata and enables Terraform to know what needs to be created, updated, or deleted.*

## Terraform Basics

### Question 5
How does Terraform use providers?

A. Providers are optional plugins used only for advanced features
B. Providers are used to authenticate users with Terraform Cloud
C. Providers are plugins that Terraform uses to manage resources and data sources
D. Providers only manage state files

**Answer: C**

*Explanation: Providers are plugins that Terraform uses to interact with various APIs, including cloud providers, SaaS providers, and other APIs. They define and manage resources and data sources for their respective platforms.*

### Question 6
What constraint would allow a module to use versions 1.2.0 through 1.9.x of a provider but not version 2.0.0?

A. `version = "1.2.0"`
B. `version = ">= 1.2.0"`
C. `version = "~> 1.2"`
D. `version = ">= 1.2.0, < 2.0.0"`

**Answer: C**

*Explanation: The `~>` operator allows the rightmost version component to increment. In this case, `~> 1.2` allows any version from 1.2.0 up to but not including 2.0.0.*

## Terraform Outside Core Workflow

### Question 7
What is the purpose of `terraform import`?

A. To import modules from the Terraform Registry
B. To bring existing infrastructure under Terraform management
C. To import state from one backend to another
D. To import variables from environment variables

**Answer: B**

*Explanation: The `terraform import` command is used to bring existing infrastructure resources that were created outside of Terraform under Terraform management by adding them to the Terraform state.*

### Question 8
Which of the following commands would you use to remove a resource from the Terraform state without destroying the actual infrastructure?

A. `terraform destroy -target=resource_type.resource_name`
B. `terraform state rm resource_type.resource_name`
C. `terraform remove resource_type.resource_name`
D. `terraform delete resource_type.resource_name`

**Answer: B**

*Explanation: The `terraform state rm` command removes a resource from the Terraform state without destroying the actual infrastructure.*

## Terraform Modules

### Question 9
When using a module from the Terraform Registry, which of the following is a valid module source format?

A. `module = "terraform-aws-modules/vpc/aws"`
B. `source = "terraform-aws-modules/vpc/aws"`
C. `registry = "terraform-aws-modules/vpc/aws"`
D. `import = "terraform-aws-modules/vpc/aws"`

**Answer: B**

*Explanation: When using a module from the Terraform Registry, the correct syntax is to specify `source = "terraform-aws-modules/vpc/aws"` in the module block.*

### Question 10
In Terraform, how can one module access outputs from another module?

A. By using the `remote_state` data source
B. By using the `module.<MODULE_NAME>.<OUTPUT_NAME>` syntax in the parent module
C. By directly referencing variables in the other module
D. Modules cannot access outputs from other modules

**Answer: B**

*Explanation: A module can access outputs from another module by using the `module.<MODULE_NAME>.<OUTPUT_NAME>` syntax, but only if both modules are called from the same parent module. Direct access between sibling modules is not possible.*

## Core Terraform Workflow

### Question 11
What does the `terraform init` command do?

A. Creates a new Terraform configuration
B. Initializes a working directory, downloads providers and modules
C. Creates the initial infrastructure
D. Initializes the state file with default values

**Answer: B**

*Explanation: The `terraform init` command initializes a working directory containing Terraform configuration files. It downloads and installs the providers and modules required by the configuration.*

### Question 12
What is the purpose of `terraform plan`?

A. To create infrastructure resources
B. To create a detailed blueprint of the infrastructure
C. To preview changes before applying them
D. To plan the lifecycle of resources

**Answer: C**

*Explanation: The `terraform plan` command creates an execution plan by comparing the current state to the desired state defined in your configuration. It shows what changes Terraform will make without actually making them.*

## Terraform State

### Question 13
What is a benefit of using a remote backend for Terraform state?

A. It eliminates the need for state entirely
B. It provides state locking to prevent concurrent operations
C. It makes Terraform run faster
D. It reduces the size of the state file

**Answer: B**

*Explanation: A major benefit of using a remote backend is state locking, which helps prevent conflicts when multiple team members are making changes to the same infrastructure concurrently.*

### Question 14
Which of the following is NOT a valid backend type for Terraform?

A. S3
B. Azure Blob Storage
C. MongoDB
D. Terraform Cloud

**Answer: C**

*Explanation: MongoDB is not a valid backend type for Terraform. Valid backends include S3, Azure Blob Storage, Google Cloud Storage, Terraform Cloud, and others, but not MongoDB.*

## Terraform Configuration

### Question 15
What will happen in the following resource block?

```hcl
resource "aws_instance" "web" {
  count = var.environment == "production" ? 3 : 1
  ami   = "ami-12345678"
  instance_type = "t2.micro"
}
```

A. It will always create 3 instances
B. It will always create 1 instance
C. It will create 3 instances if the environment variable is set to "production", otherwise 1 instance
D. It will create an instance with 3 CPUs in production or 1 CPU otherwise

**Answer: C**

*Explanation: The resource uses the count meta-argument with a conditional expression. It will create 3 instances if `var.environment` equals "production", otherwise it will create 1 instance.*

### Question 16
What does the `sensitive` attribute do when applied to a variable?

A. Encrypts the variable in the state file
B. Prevents the variable from being modified
C. Requires the variable to be passed via command line
D. Prevents the variable's value from being displayed in plans and the console output

**Answer: D**

*Explanation: The `sensitive` attribute, when set to true, prevents Terraform from displaying the variable's value in plans and console output. It does not encrypt the value in the state file or prevent modifications.*

## HCP Terraform

### Question 17
What is a feature available in HCP Terraform that is not available in Terraform Open Source?

A. The ability to use modules
B. The ability to provision resources
C. Policy enforcement with Sentinel
D. Support for AWS resources

**Answer: C**

*Explanation: Policy enforcement with Sentinel is a feature available in HCP Terraform that is not available in Terraform Open Source. Sentinel allows for fine-grained, logic-based policy decisions.*

### Question 18
In HCP Terraform, what is the purpose of workspaces?

A. To organize code into folders
B. To separate environments or components with their own state
C. To create different code editors
D. To organize providers

**Answer: B**

*Explanation: In HCP Terraform, workspaces are used to organize infrastructure and separate environments or components. Each workspace has its own state, variables, and settings.*

## Miscellaneous Topics

### Question 19
What will the following Terraform code output?

```hcl
variable "regions" {
  default = ["us-east-1", "us-west-1", "eu-west-1"]
}

output "region_count" {
  value = length(var.regions)
}
```

A. "regions"
B. ["us-east-1", "us-west-1", "eu-west-1"]
C. 3
D. Error, the length function is not valid

**Answer: C**

*Explanation: The `length` function returns the number of elements in a list, map, or string. In this case, it will return 3, which is the number of elements in the `regions` variable.*

### Question 20
What is the purpose of the `terraform.tfvars` file?

A. It's where Terraform stores the current state
B. It's where you define variables for Terraform to use
C. It's a configuration file for the Terraform CLI
D. It's used to define providers

**Answer: B**

*Explanation: The `terraform.tfvars` file is a default file name that Terraform will automatically load to populate variables with values. It's where you can define variable values for your configuration.* 