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
-   Environment-based `tfvars`

------------------------------------------------------------------------

## 📁 Repository Structure
```
.
├── config
│   └── dev.tfvars
├── locals.tf
├── main.tf
├── modules
│   ├── cluster
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ec2_capacity
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── load-balancer
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── service
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── task-definition
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── outputs.tf
├── provider.tf
├── README.md
├── terraform.tfstate
├── terraform.tfstate.backup
└── variables.tf
```
------------------------------------------------------------------------

## 📦 Supported Launch Types

| Launch Type | Supported |
|------------|----------|
| FARGATE    | ✅ Yes   |
| EC2        | ✅ Yes   |

##  Input Variables
vpc
---------------------------------------------------------------------------------
| Variable                  | Type         | Purpose                             |
| ------------------------- | ------------ | ----------------------------------- |
| `vpc_name`                | string       | Name of the VPC                     |
| `vpc_cidr`                | string       | CIDR range for the VPC              |
| `public_subnet_cidrs`     | list(string) | CIDR blocks for public subnets      |
| `private_subnet_cidrs`    | list(string) | CIDR blocks for private subnets     |               
| `cidr_block`              | string       | Allowed CIDR for routing / SG rules |
| `domain`                  | string       | Domain label for VPC resources      |
| `map_public_ip_on_launch` | bool         | Assign public IPs to instances      |
| `dns_host_name`           | bool         | Enable DNS hostnames                |
| `enable_dns_support`      | bool         | Enable DNS support                  |

load_balancer
----------------------------------------------------------------------------------------
| Variable                                         | Type         | Purpose                                                  |
| ------------------------------------------------ | ------------ | -------------------------------------------------------- |
| `name`                                           | string       | Name prefix for the load balancer and related resources  |
| `vpc_id`                                         | string       | VPC ID where the load balancer will be deployed          |
| `subnet_ids`                                     | list(string) | Subnets to attach the load balancer to                   |
| `load_balancer_type`                             | string       | Load balancer type (`application` or `network`)          |
| `internal`                                       | bool         | Whether the load balancer is internal or internet-facing |
| `enable_deletion_protection`                     | bool         | Enable or disable deletion protection                    |
| `idle_timeout`                                   | number       | Idle timeout for the load balancer (ALB only)            |
| `security_group_rules`                           | list(object) | Security group rules (ingress / egress)                  |
| `tags`                                           | map(string)  | Tags applied to all load balancer resources              |
| `target_groups`                                  | map(object)  | Map of target group configurations                       |
| `target_groups.name`                             | string       | Target group name                                        |
| `target_groups.port`                             | number       | Target group port                                        |
| `target_groups.protocol`                         | string       | Target group protocol                                    |
| `target_groups.target_type`                      | string       | Target type (`instance` for EC2, `ip` for Fargate)       |
| `target_groups.health_check.path`                | string       | Health check path                                        |
| `target_groups.health_check.matcher`             | string       | Expected HTTP success codes                              |
| `target_groups.health_check.interval`            | number       | Health check interval                                    |
| `target_groups.health_check.healthy_threshold`   | number       | Healthy threshold                                        |
| `target_groups.health_check.unhealthy_threshold` | number       | Unhealthy threshold                                      |
| `target_groups.health_check.timeout`             | number       | Health check timeout                                     |
| `listeners`                                      | map(object)  | Map of listener configurations                           |
| `listeners.port`                                 | number       | Listener port (80 for HTTP, 443 for HTTPS)               |
| `listeners.protocol`                             | string       | Listener protocol                                        |
| `listeners.target_group_key`                     | string       | Default target group for the listener                    |
| `listeners.ssl_policy`                           | string       | SSL policy for HTTPS listeners                           |
| `listeners.certificate_arn`                      | string       | ACM certificate ARN                                      |
| `listeners.rules`                                | map(object)  | Path-based routing rules                                 |
| `listeners.rules.priority`                       | number       | Listener rule priority                                   |
| `listeners.rules.path_patterns`                  | list(string) | Path patterns (e.g. `/api/*`)                            |
| `listeners.rules.target_group_key`               | string       | Target group key for rule forwarding                     |


ec2_capacity (EC2 Only)
------------------------------------------------------------------------------------------------------------------
| Variable                                         | Type         | Purpose                                       |
| ------------------------------------------------ | ------------ | --------------------------------------------- |
| `name`                                           | string       | Base name used across all created resources   |
| `use_name_prefix`                                | bool         | Use name as prefix for unique resource names  |
| `cluster_name`                                   | string       | ECS cluster name to associate instances with  |
| `create`                                         | bool         | Whether to create the Auto Scaling Group      |
| `vpc_id`                                         | string       | VPC ID where resources are deployed           |
| `availability_zones`                             | list(string) | Availability Zones for ASG instances          |
| `vpc_zone_identifier`                            | list(string) | Subnet IDs for ASG instances                  |
| `desired_capacity`                               | number       | Desired number of EC2 instances               |
| `min_size`                                       | number       | Minimum number of instances                   |
| `max_size`                                       | number       | Maximum number of instances                   |
| `desired_capacity_type`                          | string       | Capacity unit (`units`, `vcpu`, `memory-mib`) |
| `health_check_type`                              | string       | Health check type (`EC2` or `ELB`)            |
| `health_check_grace_period`                      | number       | Health check grace period (seconds)           |
| `capacity_rebalance`                             | bool         | Enable capacity rebalance                     |
| `protect_from_scale_in`                          | bool         | Protect instances from scale-in               |
| `termination_policies`                           | list(string) | ASG termination policies                      |
| `default_cooldown`                               | number       | Cooldown period between scaling activities    |
| `default_instance_warmup`                        | number       | Instance warm-up time                         |
| `max_instance_lifetime`                          | number       | Maximum lifetime of instances                 |
| `enabled_metrics`                                | list(string) | ASG CloudWatch metrics                        |
| `metrics_granularity`                            | string       | Metrics granularity                           |
| `ignore_desired_capacity_changes`                | bool         | Ignore desired capacity drift                 |
| `ignore_failed_scaling_activities`               | bool         | Ignore failed scaling activities              |
| `force_delete`                                   | bool         | Force delete ASG without draining             |
| `force_delete_warm_pool`                         | bool         | Force delete ASG warm pool                    |
| `min_elb_capacity`                               | number       | Minimum healthy instances in ELB              |
| `wait_for_elb_capacity`                          | number       | Exact healthy instances required              |
| `wait_for_capacity_timeout`                      | string       | Capacity wait timeout                         |
| `availability_zone_distribution`                 | object       | AZ capacity distribution settings             |
| `instance_maintenance_policy`                    | object       | Instance maintenance policy                   |
| `instance_refresh`                               | object       | Instance refresh configuration                |
| `warm_pool`                                      | object       | Warm pool configuration                       |
| `initial_lifecycle_hooks`                        | list(object) | Lifecycle hooks on instance launch            |
| `suspended_processes`                            | list(string) | Suspended ASG processes                       |
| `autoscaling_group_tags`                         | map(string)  | Additional ASG tags                           |
| `autoscaling_group_tags_not_propagate_at_launch` | list(string) | Tags not propagated to instances              |
| `instance_name`                                  | string       | Name tag applied to EC2 instances             |
| `timeouts.delete`                                | string       | Delete timeout for ASG                        |
| `traffic_source_attachments`                     | map(object)  | Load balancer / traffic source attachments    |
| `schedules`                                      | map(object)  | Scheduled scaling actions                     |
| `scaling_policies`                               | map(object)  | Auto scaling policies                         |
| `use_mixed_instances_policy`                     | bool         | Enable mixed instances policy                 |
| `mixed_instances_policy`                         | object       | Mixed instance configuration                  |
| `placement_group`                                | string       | Placement group name                          |
| `service_linked_role_arn`                        | string       | Service-linked role ARN                       |
| `sg_name`                                        | string       | Security group name                           |
| `security_group_rules`                           | list(object) | Security group ingress/egress rules           |
| `tags`                                           | map(string)  | Common resource tags                          |

cluster
----------------------------------------------------------------------------------
| Variable                                 | Type         | Purpose                |
| ---------------------------------------- | ------------ | ---------------------- |
| `create`                                 | bool         | Create ECS cluster     |
| `name`                                   | string       | Cluster name           |
| `tags`                                   | map(string)  | Cluster tags           |
| `configuration`                          | object       | Cluster storage config |
| `setting`                                | list(object) | Cluster settings       |
| `create_cloudwatch_log_group`            | bool         | Create log group       |
| `cloudwatch_log_group_name`              | string       | Log group name         |
| `cloudwatch_log_group_retention_in_days` | number       | Log retention          |
| `cloudwatch_log_group_kms_key_id`        | string       | KMS key                |
| `cloudwatch_log_group_class`             | string       | Log group class        |
| `cloudwatch_log_group_tags`              | map(string)  | Log group tags         |

service
-------------------------------------------------------------------------------------------------------
| Variable                             | Type         | Purpose                                        |
| ------------------------------------ | ------------ | ---------------------------------------------- |
| `name`                               | string       | ECS service name                               |
| `cluster_arn`                        | string       | ARN of the ECS cluster                         |
| `launch_type`                        | string       | Launch type (`EC2`, `FARGATE`, `EXTERNAL`)     |
| `desired_count`                      | number       | Number of running tasks                        |
| `platform_version`                   | string       | Fargate platform version                       |
| `scheduling_strategy`                | string       | Scheduling strategy (`REPLICA` or `DAEMON`)    |
| `force_new_deployment`               | bool         | Force new deployment on updates                |
| `deployment_maximum_percent`         | number       | Max percent of running tasks during deployment |
| `deployment_minimum_healthy_percent` | number       | Min healthy percent during deployment          |
| `availability_zone_rebalancing`      | string       | Enable or disable AZ rebalancing               |
| `capacity_provider_strategy`         | map(object)  | Capacity provider strategy configuration       |
| `alarms`                             | object       | CloudWatch alarm configuration                 |
| `ignore_task_definition_changes`     | bool         | Ignore task definition changes                 |
| `wait_for_steady_state`              | bool         | Wait until service reaches steady state        |
| `triggers`                           | map(string)  | Redeployment triggers                          |
| `propagate_tags`                     | string       | Propagate tags to tasks                        |
| `enable_execute_command`             | bool         | Enable ECS Exec                                |
| `assign_public_ip`                   | bool         | Assign public IP (Fargate only)                |
| `subnet_ids`                         | list(string) | Subnets for service networking                 |
| `security_group_ids`                 | list(string) | Existing security groups                       |
| `vpc_id`                             | string       | VPC ID for the service                         |
| `network_mode`                       | string       | Network mode (`awsvpc`, etc.)                  |
| `load_balancer`                      | object       | Load balancer attachment configuration         |
| `task_definition_arn`                | string       | Existing task definition ARN                   |
| `create_task_definition`             | bool         | Whether to create a task definition            |
| `container_definitions`              | any          | Container definitions JSON                     |
| `ephemeral_storage`                  | object       | Task ephemeral storage configuration           |
| `service_tags`                       | map(string)  | Additional service-specific tags               |
| `tags`                               | map(string)  | Common tags applied to all resources           |
| `create_security_group`              | bool         | Whether to create a service security group     |
| `security_group_name`                | string       | Name of the created security group             |
| `security_group_use_name_prefix`     | bool         | Use name prefix for security group             |
| `security_group_description`         | string       | Security group description                     |
| `security_group_ingress_rules`       | map(object)  | Ingress rules for service SG                   |
| `security_group_egress_rules`        | map(object)  | Egress rules for service SG                    |
| `security_group_tags`                | map(string)  | Tags for the service security group            |


task_definition
----------------------------------------------------------------------------------------------------------------------------------
| Variable                                                       | Type              | Purpose                                    |
| -------------------------------------------------------------- | ----------------- | ------------------------------------------ |
| `family`                                                       | string            | Task definition family name                |
| `cpu`                                                          | string            | CPU units for the task                     |
| `memory`                                                       | string            | Memory for the task                        |
| `network_mode`                                                 | string            | Network mode (`awsvpc`, `host`, `bridge`)  |
| `requires_compatibilities`                                     | list(string)      | ECS launch compatibilities (EC2 / Fargate) |
| `launch_type`                                                  | string            | Launch type for ECS service                |
| `container_definitions`                                        | map(object)       | Map of container configurations            |
| `container_definitions.create`                                 | bool              | Whether to create the container definition |
| `container_definitions.name`                                   | string            | Container name                             |
| `container_definitions.image`                                  | string            | Container image                            |
| `container_definitions.cpu`                                    | number            | Container CPU units                        |
| `container_definitions.memory`                                 | number            | Hard memory limit                          |
| `container_definitions.memoryReservation`                      | number            | Soft memory limit                          |
| `container_definitions.essential`                              | bool              | Whether container is essential             |
| `container_definitions.command`                                | list(string)      | Container command                          |
| `container_definitions.entrypoint`                             | list(string)      | Container entrypoint                       |
| `container_definitions.environment`                            | list(map(string)) | Environment variables                      |
| `container_definitions.secrets`                                | list(object)      | Secrets from SSM / Secrets Manager         |
| `container_definitions.portMappings`                           | list(object)      | Port mappings                              |
| `container_definitions.healthCheck`                            | object            | Container health check                     |
| `container_definitions.enable_cloudwatch_logging`              | bool              | Enable CloudWatch logging                  |
| `container_definitions.create_cloudwatch_log_group`            | bool              | Create CloudWatch log group                |
| `container_definitions.cloudwatch_log_group_name`              | string            | Log group name                             |
| `container_definitions.cloudwatch_log_group_use_name_prefix`   | bool              | Use name prefix for log group              |
| `container_definitions.cloudwatch_log_group_class`             | string            | Log group class                            |
| `container_definitions.cloudwatch_log_group_retention_in_days` | number            | Log retention period                       |
| `container_definitions.cloudwatch_log_group_kms_key_id`        | string            | KMS key for logs                           |
| `container_definitions.logConfiguration`                       | any               | Custom log configuration                   |
| `ephemeral_storage`                                            | object            | Ephemeral storage configuration            |
| `ephemeral_storage.size_in_gib`                                | number            | Ephemeral storage size                     |
| `volumes`                                                      | map(object)       | Task volumes / EFS configuration           |
| `create_task_definition`                                       | bool              | Whether to create task definition          |
| `skip_destroy`                                                 | bool              | Skip destroy of task definition            |
| `track_latest`                                                 | bool              | Track latest task definition revision      |
| `enable_fault_injection`                                       | bool              | Enable fault injection                     |
| `create_task_execution_role`                                   | bool              | Create task execution IAM role             |
| `task_execution_role_name`                                     | string            | Task execution IAM role name               |
| `task_execution_role_description`                              | string            | Task execution role description            |
| `external_task_execution_role_arn`                             | string            | External task execution role ARN           |
| `task_execution_custom_policies`                               | string            | Custom execution role policies (JSON)      |
| `task_execution_role_tags`                                     | map(string)       | Tags for execution IAM role                |
| `tasks_exec_iam_role_policies`                                 | map(string)       | Additional execution role policy ARNs      |
| `create_tasks_iam_role`                                        | bool              | Create ECS task IAM role                   |
| `tasks_iam_role_arn`                                           | string            | Existing task IAM role ARN                 |
| `tasks_iam_role_name`                                          | string            | Task IAM role name                         |
| `tasks_iam_role_use_name_prefix`                               | bool              | Use name prefix for task IAM role          |
| `tasks_iam_role_path`                                          | string            | IAM role path                              |
| `tasks_iam_role_description`                                   | string            | Task IAM role description                  |
| `tasks_iam_role_permissions_boundary`                          | string            | IAM permissions boundary ARN               |
| `tasks_iam_role_tags`                                          | map(string)       | Tags for task IAM role                     |
| `tasks_iam_role_policies`                                      | map(string)       | Additional task IAM role policies          |
| `tasks_iam_role_statements`                                    | list(object)      | Custom IAM policy statements               |
| `tasks_iam_role_max_session_duration`                          | number            | Max IAM session duration                   |
| `tasks_iam_role_assume_policy`                                 | string            | Pre-generated assume role policy JSON      |
| `tasks_iam_role_policy_json`                                   | string            | Pre-generated IAM policy JSON              |
| `tags`                                                         | map(string)       | Common resource tags                       |
| `task_tags`                                                    | map(string)       | Additional task definition tags            |




## ▶️ Usage

``` bash
terraform init
terraform plan -var-file=config/dev.tfvars
terraform apply -var-file=config/dev.tfvars
```
## 🚨 Important Notes
| Rule                        | Requirement                                                   |
| --------------------------- | ------------------------------------------------------------- |
| **FARGATE**                 | No EC2 capacity configuration required                        |
| **EC2**                     | `ec2_capacity` **must be provided**                           |
| **Service ↔ Task Mapping**  | `service` and `task_definition` **MUST use the same map key** |
| **Multi-service Setup**     | Each service requires a matching task definition key          |
| **Launch Type Consistency** | `launch_type` and `requires_compatibilities` must match       |
| **Launch Type ** | `launch_type=FARGTE` for farget and EC2 for EC2 mode `requires_compatibilities` must match       |


## 🖥️ EC2 Capacity Configuration (Required for EC2)

When using EC2 launch type, you must define the ec2_capacity block to provision Auto Scaling capacity for the ECS cluster.
```
ecs_ec2_capacity = {
  create          = true
  name            = "ecs-ec2-prod"
  cluster_name    = "prod-ecs-cluster"
  use_name_prefix = true
  sg_name         = "instance_sg"

  security_group_rules = [
    {
      type       = "ingress"
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = ["10.0.0.0/24"]
    },
    {
      type       = "ingress"
      from_port  = 8080
      to_port    = 8080
      protocol   = "tcp"
      cidr_block = ["10.0.0.0/24"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  min_size         = 1
  max_size         = 4
  desired_capacity = 2

  instance_type = "t3.large"

  create_iam_instance_profile = true
  iam_role_name               = "ecs-ec2-role"
  iam_role_policies = {
    ecs = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  managed_scaling_status         = "ENABLED"
  target_capacity                = 100
  minimum_scaling_step_size      = 1
  maximum_scaling_step_size      = 4
  managed_termination_protection = "ENABLED"

  tags = {
    Owner = "platform-team"
  }
}
```
------------------------------------------------------------------------

## 🧪 Example: EC2-based ECS Services  (WordPress + MySQL) & Nginx

This example deploys WordPress and MySQL in 1st service and Nginx on 2nd  using **EC2 launch
type**, an **ALB with instance targets**, and `network_mode = host`.
```
vpc = {
  vpc_name                = "my-wordpress-vpc"
  vpc_cidr                = "10.0.0.0/24"
  public_subnet_cidrs     = ["10.0.0.0/26", "10.0.0.64/26"]
  private_subnet_cidrs    = ["10.0.0.128/26", "10.0.0.192/26"]
  cidr_block              = "0.0.0.0/0"
  domain                  = "vpc"
  map_public_ip_on_launch = true
  enable_dns_support      = true
  dns_host_name           = true

}
cluster = {
  create = true
  name   = "dev-ecs-cluster"
  tags = {
    Project = "wordpress-app"
  }
  setting = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_name              = "/aws/ecs/dev-ecs-cluster"
  cloudwatch_log_group_retention_in_days = 14
  cloudwatch_log_group_class             = "STANDARD"
  cloudwatch_log_group_tags              = { Environment = "dev" }
  cloudwatch_log_group_kms_key_id        = "d33f023a-8e2f-47a5-8fa7-22adf1f65d13"
}
load_balancer = {
  name                       = "my-alb"
  protocol                   = "HTTP"
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = false
  idle_timeout               = 120

  security_group_rules = [
    {
      type        = "ingress"
      description = "HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  target_groups = {
    wordpress = {
      name        = "wordpress-tg"
      port        = 80
      protocol    = "HTTP"
      target_type = "instance"
      health_check = { # ← CORRECT: health_check object
        path                = "/wp-login.php"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    },
    nginx = {
      name        = "nginx-tg"
      port        = 8080
      protocol    = "HTTP"
      target_type = "instance"
      health_check = {
        path                = "/"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    },
  }
  listeners = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "wordpress" # Default routing
      rules = {
        nginx_path = {
          priority         = 10
          path_patterns    = ["/nginx*"]
          target_group_key = "nginx"
        }
      }

    },
  }
  tags = {
    Application = "myapp"
  }
}
launch_type = "EC2"
service = {
  wordpress = {
    name           = "wordpress-service"
    desired_count  = 1

    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false

    assign_public_ip = false

    load_balancer = {

      container_name = "wordpress"
      container_port = 80

    }
    create_security_group          = true
    security_group_name            = "wordpress-sg"
    security_group_use_name_prefix = true
    security_group_description     = "ECS service SG"
    security_group_ingress_rules = {
      http = { cidr_ipv4 = "10.0.0.0/24", from_port = 80, to_port = 80, ip_protocol = "tcp" },
      lb_to_app = {
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        description = "Load balancer to app"
      },
    }
    security_group_egress_rules = {
      all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
    }
    security_group_tags = { Description = "custom service sg for every service" }


    tags = {
      Desc = "dev"
    }
  }

  nginx = {
    name           = "nginx-service"
    desired_count  = 1

    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false

    assign_public_ip = false

    load_balancer = {

      container_name = "nginx"
      container_port = 8080

    }
    create_security_group          = true
    security_group_name            = "nginx-sg"
    security_group_use_name_prefix = true
    security_group_description     = "ECS service SG for nginx"
    security_group_ingress_rules = {
      http = { cidr_ipv4 = "10.0.0.0/24", from_port = 8080, to_port = 8080, ip_protocol = "tcp" },
      lb_to_app = {
        from_port   = 8080
        to_port     = 8080
        ip_protocol = "tcp"
        description = "Load balancer to app"
      },
    }
    security_group_egress_rules = {
      all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
    }

  }
}
base_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
task_definition = {
  wordpress = {
    dependsOn = [
      {
        containerName = "mysql"
        condition     = "HEALTHY"
      }
    ]
    create_task_definition   = true
    family                   = "wordpress"
    cpu                      = 1024
    memory                   = 2048
    network_mode             = "host"
    task_execution_role_name = "ecsTaskExecutionRole"
    task_exec_role_policies = {
      secrets = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
    }
    create_tasks_role = true
    task_role_name    = "my-app-task-role"

    task_role_statements = [
      {
        actions   = ["s3:GetObject", "s3:PutObject"]
        resources = ["arn:aws:s3:::my-data-bucket/*"]
        effect    = "Allow"
      },
    ]
    ephemeral_storage = {
      size_in_gib = 21
    }

    container_definitions = {
      wordpress = {
        image     = "wordpress:latest"
        cpu       = 256
        memory    = 512
        essential = true

        portMappings = [{
          containerPort = 80
          protocol      = "tcp"
        }]
        enable_cloudwatch_logging              = true # This is the key switch!
        create_cloudwatch_log_group            = true
        cloudwatch_log_group_name              = "/ecs/wordpress"
        cloudwatch_log_group_use_name_prefix   = false
        cloudwatch_log_group_class             = "STANDARD"
        cloudwatch_log_group_retention_in_days = 14

        healthCheck = {
          command = ["CMD-SHELL",
          "curl -f http://localhost/wp-login.php || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 120
        }

        # secrets = [
        #   {
        #     name      = "WORDPRESS_DB_USER"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:username::"
        #   },
        #   {
        #     name      = "WORDPRESS_DB_PASSWORD"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:password::"
        #   },
        #   {
        #     name      = "WORDPRESS_DB_NAME"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:database::"
        #   }
        # ]


        environment = [
          { name = "WORDPRESS_DB_HOST", value = "127.0.0.1:3306" },
          { name = "WORDPRESS_DB_USER", value = "wpuser" },
          { name = "WORDPRESS_DB_PASSWORD", value = "wppassword" },
          { name = "WORDPRESS_DB_NAME", value = "wordpress" }
        ]
      }

      mysql = {
        image     = "mysql:8.0"
        cpu       = 256
        memory    = 512
        essential = true

        portMappings = [{
          containerPort = 3306
          protocol      = "tcp"
        }]
        enable_cloudwatch_logging              = true # This is the key switch!
        create_cloudwatch_log_group            = true
        cloudwatch_log_group_name              = "/ecs/mysql"
        cloudwatch_log_group_use_name_prefix   = false
        cloudwatch_log_group_class             = "STANDARD"
        cloudwatch_log_group_retention_in_days = 14
        healthCheck = {
          command     = ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -uroot -p$MYSQL_ROOT_PASSWORD"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 60
        }

        environment = [
          { name = "MYSQL_DATABASE", value = "wordpress" },
          { name = "MYSQL_USER", value = "wpuser" },
          { name = "MYSQL_PASSWORD", value = "wppassword" },
          { name = "MYSQL_ROOT_PASSWORD", value = "rootpassword" }
        ]
        # secrets = [
        #   {
        #     name      = "MYSQL_USER"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:username::"
        #   },
        #   {
        #     name      = "MYSQL_PASSWORD"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:password::"
        #   },
        #   {
        #     name      = "MYSQL_DATABASE"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:database::"
        #   },
        #   {
        #     name      = "MYSQL_ROOT_PASSWORD"
        #     valueFrom = "arn:aws:secretsmanager:us-east-1:569023477847:secret:wordpress/mysql-riIZst:root_password::"
        #   }
        # ]
      }
    }

  }
  nginx = {
    create_task_definition = true
    family                 = "nginx"
    cpu                    = 1024
    memory                 = 2048
    network_mode           = "host"

    task_execution_role_name = "ecsTaskExecutionRole_nginx"
    create_tasks_role        = false
    #  external_task_role_arn   = "arn:aws:iam::569023477847:role/my-app-task-role-20260105112735151900000002"

    ephemeral_storage = {
      size_in_gib = 21
    }

    container_definitions = {
      nginx = {
        image     = "nginx:alpine"
        cpu       = 256
        memory    = 512
        essential = true

        portMappings = [{
          containerPort = 8080
          protocol      = "tcp"
        }]
        command                                = ["sh", "-c", "sed -i 's/listen       80;/listen       8080;/' /etc/nginx/conf.d/default.conf && mkdir -p /usr/share/nginx/html/nginx && cp /usr/share/nginx/html/index.html /usr/share/nginx/html/nginx/ && nginx -g 'daemon off;'"]
        create_cloudwatch_log_group            = true
        cloudwatch_log_group_name              = "/ecs/nginx"
        cloudwatch_log_group_use_name_prefix   = false
        cloudwatch_log_group_class             = "STANDARD"
        cloudwatch_log_group_retention_in_days = 14
        healthCheck = {
          command     = ["CMD-SHELL", "curl -f http://localhost:8080/ || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 120
        }
        environment = [
        ]
      }
    }
  }
}
ecs_ec2_capacity = {
  create          = true
  name            = "ecs-ec2-prod"
  cluster_name    = "prod-ecs-cluster"
  use_name_prefix = true
  sg_name         = "instance_sg"

  security_group_rules = [
    {
      type       = "ingress"
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = ["10.0.0.0/24"]
    },
    {
      type       = "ingress"
      from_port  = 8080
      to_port    = 8080
      protocol   = "tcp"
      cidr_block = ["10.0.0.0/24"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  min_size         = 1
  max_size         = 4
  desired_capacity = 2

  instance_type = "t3.large"

  create_iam_instance_profile = true
  iam_role_name               = "ecs-ec2-role"
  iam_role_policies = {
    ecs = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    ssm = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  managed_scaling_status         = "ENABLED"
  target_capacity                = 100
  minimum_scaling_step_size      = 1
  maximum_scaling_step_size      = 4
  managed_termination_protection = "ENABLED"

  tags = {
    Owner = "platform-team"
  }
}
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