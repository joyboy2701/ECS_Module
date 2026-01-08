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
| `environment`             | string       | Environment name (dev/stage/prod)   |
| `subnet_types`            | map(string)  | Mapping of subnet names to type     |
| `public_subnet_cidrs`     | list(string) | CIDR blocks for public subnets      |
| `private_subnet_cidrs`    | list(string) | CIDR blocks for private subnets     |               
| `cidr_block`              | string       | Allowed CIDR for routing / SG rules |
| `domain`                  | string       | Domain label for VPC resources      |
| `map_public_ip_on_launch` | bool         | Assign public IPs to instances      |
| `dns_host_name`           | bool         | Enable DNS hostnames                |
| `enable_dns_support`      | bool         | Enable DNS support                  |

load_balancer
----------------------------------------------------------------------------------------
| Variable                          | Type         | Purpose                            |
| --------------------------------- | ------------ | ---------------------------------- |
| `name`                            | string       | Load balancer name                 |
| `target_port`                     | number       | Target group port                  |
| `listnert_port`                   | number       | Listner  port  80 for HTTP/ 443 for HTTPS                 |
| `protocol`                        | string       | Listener protocol                  |
| `load_balancer_type`              | string       | ALB or NLB                         |
| `target_type`                     | string       | `instance` (EC2) or `ip` (Fargate) |
| `internal`                        | bool         | Internal or internet-facing LB     |
| `enable_deletion_protection`      | bool         | Enable deletion protection         |
| `idle_timeout`                    | number       | ALB idle timeout                   |
| `healthcheck_healthy_threshold`   | number       | Healthy threshold                  |
| `healthcheck_unhealthy_threshold` | number       | Unhealthy threshold                |
| `healthcheck_timeout`             | number       | Health check timeout               |
| `healthcheck_interval`            | number       | Health check interval              |
| `action_type`                     | string       | Listener action                    |
| `matcher`                         | string       | HTTP success codes                 |
| `healthCheck_path`                | string       | Health check path                  |
| `security_group_rules`            | list(object) | LB security rules                  |
| `tags`                            | map(string)  | Resource tags                      |

ec2_capacity (EC2 Only)
---------------------------------------------------------------------------
| Variable                         | Type         | Purpose                |
| -------------------------------- | ------------ | ---------------------- |
| `instance_type`                  | string       | EC2 instance type      |
| `desired_capacity`               | number       | Desired instance count |
| `min_size`                       | number       | Minimum instances      |
| `max_size`                       | number       | Maximum instances      |
| `managed_termination_protection` | string       | Protect running tasks  |
| `maximum_scaling_step_size`      | number       | Max scaling step       |
| `minimum_scaling_step_size`      | number       | Min scaling step       |
| `target_capacity`                | number       | ECS target utilization |
| `managed_scaling_status`         | string       | Enable managed scaling |
| `sg_name`                        | string       | Security group name    |
| `security_group_rules`           | list(object) | EC2 security rules     |
| `tags`                           | map(string)  | Resource tags          |

cluster
----------------------------------------------------------------------------------
| Variable                                 | Type         | Purpose                |
| ---------------------------------------- | ------------ | ---------------------- |
| `create`                                 | bool         | Create ECS cluster     |
| `name`                                   | string       | Cluster name           |
| `region`                                 | string       | AWS region             |
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
---------------------------------------------------------------------
| Variable                 | Type         | Purpose                  |
| ------------------------ | ------------ | ------------------------ |
| `create_service`         | bool         | Create ECS service       |
| `name`                   | string       | Service name             |
| `launch_type`            | string       | `EC2` or `FARGATE`       |
| `desired_count`          | number       | Number of tasks          |
| `assign_public_ip`       | bool         | Fargate only             |
| `subnet_ids`             | list(string) | Service subnets          |
| `security_group_ids`     | list(string) | Existing SGs             |
| `load_balancer`          | map(object)  | LB attachment            |
| `create_task_definition` | bool         | Create task definition   |
| `task_definition_arn`    | string       | Existing task definition |
| `enable_execute_command` | bool         | Enable ECS Exec          |
| `create_security_group`  | bool         | Create service SG        |
| `container_definitions`  | any          | Container configuration  |
| `ephemeral_storage`      | object       | Task storage             |
| `tags`                   | map(string)  | Service tags             |

task_definition
---------------------------------------------------------------------------
| Variable                     | Type         | Purpose                    |
| ---------------------------- | ------------ | -------------------------- |
| `family`                     | string       | Task definition family     |
| `cpu`                        | string       | Task CPU                   |
| `memory`                     | string       | Task memory                |
| `network_mode`               | string       | `awsvpc`, `host`, `bridge` |
| `requires_compatibilities`   | list(string) | EC2 / Fargate              |
| `launch_type`                | string       | Launch type                |
| `container_definitions`      | map(object)  | Containers config          |
| `ephemeral_storage`          | object       | Storage configuration      |
| `volumes`                    | map(object)  | Volumes / EFS              |
| `create_task_execution_role` | bool         | Create IAM role            |
| `task_execution_role_name`   | string       | IAM role name              |
| `tags`                       | map(string)  | Resource tags              |



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

## 🧪 Example: EC2-based ECS Service (WordPress + MySQL)

This example deploys WordPress and MySQL on ECS using **EC2 launch
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
    create_service = true
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
    create_service = true
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