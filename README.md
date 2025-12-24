# ECS Terraform 

This repository provisions a **dynamic Amazon ECS platform** supporting
**both Fargate and EC2 launch types**. It is modular, environment-aware,
and production-ready.

------------------------------------------------------------------------

## 🚀 Features

-   ECS cluster with **Fargate & EC2** support
-   EC2 Auto Scaling via **capacity providers**
-   ALB / NLB support with health checks
-   Multiple ECS services (map-based)
-   Per-service security groups & IAM
-   CloudWatch logging
-   Environment-based tfvars

------------------------------------------------------------------------

## 📁 Repository Structure

    .
    ├── config/
    │   └── dev.tfvars              # Environment-specific variables
    ├── data.tf                     # Data sources (VPC, AMIs, etc.)
    ├── main.tf                     # Root module wiring
    ├── provider.tf                 # AWS provider configuration
    ├── variables.tf                # Root input variables
    ├── outputs.tf                  # Root outputs
    ├── versions.tf                 # Terraform & provider versions
    ├── README.md                   # Project documentation
    │
    ├── modules/
    │   ├── vpc/                    # VPC, subnets, routing, DNS
    │   ├── load-balancer/          # ALB / NLB + target groups
    │   ├── cluster/                # ECS cluster & capacity providers
    │   ├── ec2_capacity/           # EC2 Auto Scaling for ECS
    │   ├── container-definition/   # Task container definitions
    │   └── service/                # ECS services & task definitions
    │
    ├── terraform.tfstate           # Terraform state (local)
    └── terraform.tfstate.backup

------------------------------------------------------------------------

## 🧩 Module Responsibilities

### `modules/vpc`

-   Creates VPC, public/private subnets
-   DNS, routing, IGW/NAT support

### `modules/load-balancer`

-   ALB/NLB creation
-   Listeners & target groups
-   Health checks and security groups

### `modules/cluster`

-   ECS cluster
-   Capacity providers
-   CloudWatch log groups

### `modules/ec2_capacity`

-   Auto Scaling Group
-   Managed ECS scaling
-   Instance lifecycle management

### `modules/container-definition`

-   Reusable container definitions
-   Environment variables
-   Logging configuration

### `modules/service`

-   ECS services
-   Task definitions
-   Load balancer attachment
-   Networking & IAM

------------------------------------------------------------------------

## 📦 Supported Launch Types

  Launch Type    Supported
  -------------  -----------
  FARGATE        Yes
  EC2            Yes

------------------------------------------------------------------------

## ▶️ Usage

``` bash
terraform init
terraform plan -var-file=config/dev.tfvars
terraform apply -var-file=config/dev.tfvars
```

------------------------------------------------------------------------

## 🔐 Security

-   Per-service security groups
-   IAM roles per task & execution
-   Private subnet support

------------------------------------------------------------------------

## 📊 Observability

-   CloudWatch Logs
-   Load balancer health checks
-   ECS service events

------------------------------------------------------------------------

## 🧠 Design Principles

-   Highly modular
-   Map-based services
-   Environment isolation
-   Production defaults

------------------------------------------------------------------------

