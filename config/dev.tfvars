vpc = {
  vpc_name                = "my-app-vpc"
  vpc_cidr                = "10.0.0.0/24"
  public_subnet_cidrs     = ["10.0.0.0/26", "10.0.0.64/26"]
  private_subnet_cidrs    = ["10.0.0.128/26", "10.0.0.192/26"]
  cidr_block              = "0.0.0.0/0"
  domain                  = "vpc"
  service_discovery_name  = "service.local"
  map_public_ip_on_launch = true
  enable_dns_support      = true
  dns_host_name           = true
}
base_tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}
cluster = {
  name = "ecs-cluster"
  tags = {
    Project = "api-worker-app"
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
  name               = "api-alb"
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
    api = {
      name        = "api-tg"
      port        = 80
      protocol    = "HTTP"
      target_type = "ip"
      health_check = {
        path                = "/health"
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
      target_group_key = "api"
    }
  }

  tags = {
    Application = "api-worker-app"
  }
}
service = {
  api = {
    name          = "api-service"
    desired_count = 1
    launch_type   = "FARGATE"

    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false

    assign_public_ip = false # Private subnet
    load_balancer = {
      container_name = "api"
      container_port = 80
    }

    create_security_group      = true
    security_group_name        = "api-sg"
    security_group_description = "ECS API SG"
    security_group_ingress_rules = {
      # Allow ALB to reach API
      lb_to_app = {
        from_port   = 80
        to_port     = 80
        ip_protocol = "tcp"
        description = "ALB to API"
      }
    }
    security_group_egress_rules = {
      all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
    }

  }

  worker = {
    name                               = "worker-service"
    desired_count                      = 1
    launch_type                        = "EC2"
    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false
    enable_service_discovery           = true

    assign_public_ip           = false # Private subnet
    create_security_group      = true
    security_group_name        = "worker-sg"
    security_group_description = "ECS Worker SG"
    security_group_ingress_rules = {
      http = { cidr_ipv4 = "10.0.0.0/24", from_port = 8080, to_port = 8080, ip_protocol = "tcp" },
    }
    security_group_egress_rules = {
      all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
    }

  }
}

task_definition = {
  api = {
    family                   = "api"
    cpu                      = 512
    memory                   = 1024
    network_mode             = "awsvpc"
    task_execution_role_name = "ecsTaskExecutionRole"
    create_tasks_role        = false

    container_definitions = {
      api = {
        image                                  = "569023477847.dkr.ecr.us-east-1.amazonaws.com/upload-api:1.1"
        cpu                                    = 256
        memory                                 = 512
        essential                              = true
        portMappings                           = [{ containerPort = 80, protocol = "tcp" }]
        enable_cloudwatch_logging              = true
        create_cloudwatch_log_group            = true
        cloudwatch_log_group_name              = "/ecs/api"
        cloudwatch_log_group_retention_in_days = 14
        environment = [
          {
            name  = "STORAGE_SERVICE_URL"
            value = "http://worker-service.service.local:8080"
          }
        ]
      }
    }
  }

  worker = {
    family                   = "worker"
    cpu                      = 512
    memory                   = 1024
    network_mode             = "awsvpc"
    task_execution_role_name = "ecsTaskExecutionRole_worker"
    create_tasks_role        = false

    container_definitions = {
      worker = {
        image     = "569023477847.dkr.ecr.us-east-1.amazonaws.com/storage-service:1.1"
        cpu       = 256
        memory    = 512
        essential = true
        portMappings = [{
          containerPort = 8080
          protocol      = "tcp"
        }]

        enable_cloudwatch_logging              = true
        create_cloudwatch_log_group            = true
        cloudwatch_log_group_name              = "/ecs/worker"
        cloudwatch_log_group_retention_in_days = 14
        healthCheck = {
          command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 10
        }
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
  max_size         = 3
  desired_capacity = 1
  instance_type    = "t2.medium"

  create_iam_instance_profile = true
  iam_role_name               = "ecs-ec2-role"
  iam_role_policies = {
    ecs = "AmazonEC2ContainerServiceforEC2Role"
    ssm = "AmazonSSMManagedInstanceCore"
  }

  managed_scaling_status = "ENABLED"
  target_capacity        = 100
  tags                   = { Owner = "platform-team" }
}
