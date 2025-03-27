# Terraform Associate Certification Practice

A comprehensive collection of practice exercises and study materials for the HashiCorp Terraform Associate certification. This repository covers both AWS and GCP implementations while focusing on core Terraform concepts.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## About This Project

This project aims to help you prepare for the [HashiCorp Terraform Associate (003) Certification](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003) by providing hands-on exercises for both AWS and Google Cloud Platform. The exercises follow a structured approach to reinforce key concepts that are tested in the exam.

### Exam Details

- **Duration**: 1 hour
- **Question Format**: Multiple choice
- **Passing Score**: Not specified (aim for >70%)
- **Price**: $70.50 USD
- **Validity**: 2 years

For more information, see the [official exam details](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003).

## Study Materials

This guide is organized to align with the official exam objectives. Follow this structured approach to maximize your learning:

1. [Infrastructure as Code Concepts](01-iac-concepts.md)
2. [Purpose of Terraform](02-terraform-purpose.md)
3. [Terraform Basics](03-terraform-basics.md)
4. [Terraform Outside Core Workflow](04-terraform-outside-workflow.md)
5. [Terraform Modules](05-terraform-modules.md)
6. [Core Terraform Workflow](06-core-workflow.md)
7. [Implement and Maintain State](07-terraform-state.md)
8. [Read and Write Configuration](08-terraform-configuration.md)
9. [HCP Terraform Capabilities](09-hcp-terraform.md)
10. [Practice Exercises](exercises/README.md)
11. [Sample Questions](sample-questions.md)

## Repository Structure

The practice exercises are available for both AWS and GCP:

```
terraform-associate/
├── 01-iac-concepts.md
├── 02-terraform-purpose.md
├── ... (other study guide files)
├── exercises/
│   ├── 01-first-config/
│   │   ├── aws/
│   │   └── gcp/
│   ├── 02-variables-and-outputs/
│   │   ├── aws/
│   │   └── gcp/
│   ├── 03-resource-dependencies/
│   │   ├── aws/
│   │   └── gcp/
│   ├── 04-working-with-state/
│   │   ├── aws/
│   │   └── gcp/
│   ├── 05-modules/
│   │   ├── aws/
│   │   └── gcp/
│   └── 06-meta-arguments/
│       ├── aws/
│       └── gcp/
└── exam-notes/
    ├── core-concepts.md
    ├── provider-configuration.md
    ├── state-management.md
    └── resource-management.md
```

## Certification Topics Covered

1. **Infrastructure as Code Concepts** - [Exam Objective 1](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003#infrastructure-as-code-concepts)
   - Understanding IaC principles
   - Terraform's place in the IaC ecosystem
   - Benefits and challenges of IaC

2. **Terraform Purpose and Workflow** - [Exam Objective 2 & 6](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003#terraform-fundamentals)
   - Core Terraform workflow
   - Terraform language basics
   - State management
   - Provider utilization

3. **Resource Management** - [Exam Objective 8](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003#read-generate-and-modify-configuration)
   - Resource types
   - Resource dependencies
   - Resource meta-arguments
   - Resource lifecycle

4. **Terraform Modules** - [Exam Objective 5](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003#interact-with-terraform-modules)
   - Module structure
   - Module sources
   - Module versioning
   - Module composition

5. **HCP Terraform Capabilities** - [Exam Objective 9](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003#hcp-terraform-capabilities)
   - Terraform Cloud
   - Workspaces
   - Remote execution
   - Team and governance features

## Prerequisites

- Terraform installed (v1.0.0 or newer)
- AWS account with appropriate permissions (for AWS exercises)
- Google Cloud account with appropriate permissions (for GCP exercises)
- Basic understanding of cloud services

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/terraform-associate.git
   cd terraform-associate
   ```

2. How to use this guide:
   - **Theoretical Study**: Work through the study guide files (01-iac-concepts.md through 09-hcp-terraform.md)
   - **Hands-on Practice**: Choose your preferred cloud provider (AWS or GCP) and complete the exercises
   - **Test Yourself**: Use the sample questions to gauge your readiness

3. Follow the README instructions in each exercise directory

4. Complete the exercises and challenges

5. Review the provided solutions

## Study Plan

For a structured study approach, follow this 7-day plan:

| Day | Focus Areas | Activities |
|-----|-------------|------------|
| 1 | Infrastructure as Code & Purpose of Terraform | Read sections 1-2, complete Exercise 1 |
| 2 | Terraform Basics | Read section 3, complete Exercise 2 |
| 3 | Core Workflow & Modules | Read sections 5-6, complete Exercise 3 |
| 4 | Working with State & Outside Core Workflow | Read sections 4 & 7, complete Exercise 4 |
| 5 | Advanced Configuration | Read section 8, complete Exercise 5 |
| 6 | HCP Terraform & Meta-Arguments | Read section 9, complete Exercise 6 |
| 7 | Practice & Review | Review all materials, take sample questions |

## Additional Resources

- [Official HashiCorp Learn Tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Official Exam Review Guide](https://developer.hashicorp.com/terraform/tutorials/certification-003/associate-review-003)

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 