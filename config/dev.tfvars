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
  name = "ecs-cluster"
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
  cloudwatch_log_group_name              = "/aws/ecs/ecs-cluster"
  cloudwatch_log_group_retention_in_days = 14
  cloudwatch_log_group_class             = "STANDARD"
  cloudwatch_log_group_kms_key_id        = "alias/cloud_watch"
}
load_balancer = {
  name               = "my-alb"
  protocol           = "HTTP"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 120

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
      target_type = "ip"
      health_check = { # ← CORRECT: health_check object
        path                = "/wp-login.php"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    }
  }
  listeners = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "wordpress" # Default routing
    },
  }
  tags = {
    Application = "myapp"
  }
}
service = {
  wordpress = {
    name          = "wordpress-service"
    desired_count = 1

    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false

    assign_public_ip = true

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
  }
  mysql = {
    name          = "mysql-service"
    desired_count = 1

    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false
    launch_type                        = "EC2"

    assign_public_ip = false

    create_security_group          = true
    security_group_name            = "mysql-sg"
    security_group_use_name_prefix = true
    security_group_description     = "ECS service SG"
    security_group_ingress_rules = {
      http = { cidr_ipv4 = "10.0.0.0/24", from_port = 3306, to_port = 3306, ip_protocol = "tcp" },
      
    }
    security_group_egress_rules = {
      all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
    }
    security_group_tags = { Description = "custom service sg for every service" }
  }

  
}
base_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
task_definition = {
  wordpress = {
    family                   = "wordpress"
    cpu                      = 1024
    memory                   = 2048
    network_mode             = "awsvpc"
    task_execution_role_name = "ecsTaskExecutionRole"
    task_exec_role_policies = {
      secrets = "SecretsManagerReadWrite"
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
        secrets = [
          {
            name      = "WORDPRESS_DB_USER"
            valueFrom = "wordpress/mysql:username::"
          },
          {
            name      = "WORDPRESS_DB_PASSWORD"
            valueFrom = "wordpress/mysql:password::"
          },
          {
            name      = "WORDPRESS_DB_NAME"
            valueFrom = "wordpress/mysql:database::"
          }
        ]


        environment = [
          { name = "WORDPRESS_DB_HOST", value = "10.0.0.200:3306" },
        ]
      }

      
    }

  }
  mysql = {
    family       = "mysql"
    cpu          = 1024
    memory       = 2048
    network_mode = "awsvpc"

    task_execution_role_name = "ecsTaskExecutionRole_mysql"
    create_tasks_role        = false
     task_exec_role_policies = {
      secrets = "SecretsManagerReadWrite"
    }
    container_definitions = {
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

        secrets = [
          {
            name      = "MYSQL_USER"
            valueFrom = "wordpress/mysql:username::"
          },
          {
            name      = "MYSQL_PASSWORD"
            valueFrom = "wordpress/mysql:password::"
          },
          {
            name      = "MYSQL_DATABASE"
            valueFrom = "wordpress/mysql:database::"
          },
          {
            name      = "MYSQL_ROOT_PASSWORD"
            valueFrom = "wordpress/mysql:root_password::"
          }
        ]
      }
    }
  }
}


ecs_ec2_capacity = {
  name            = "ecs-ec2"
  cluster_name    = "ecs-cluster"
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
      from_port  = 3306
      to_port    = 3306
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
  desired_capacity = 1

  instance_type = "t2.medium"

  create_iam_instance_profile = true
  iam_role_name               = "ecs-ec2-role"
  iam_role_policies = {
    ecs = "AmazonEC2ContainerServiceforEC2Role"
    ssm = "AmazonSSMManagedInstanceCore"
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