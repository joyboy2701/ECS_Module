vpc = {
  vpc_name             = "my-wordpress-vpc"
  vpc_cidr             = "10.0.0.0/24"
  public_subnet_cidrs  = ["10.0.0.0/26", "10.0.0.64/26"] # Within 10.0.0.0/24
  private_subnet_cidrs = ["10.0.0.128/26", "10.0.0.192/26"]
  azs                  = ["us-east-1a", "us-east-1b"]
  environment          = "dev"
  subnet_types = {
    public  = "public"
    private = "private"
  }
  cidr_block              = "0.0.0.0/0"
  domain                  = "vpc"
  map_public_ip_on_launch = true
  enable_dns_support      = true
  dns_host_name           = true

}
load_balancer = {
  name                            = "my-alb"
  target_port                     = 80
  protocol                        = "HTTP"
  load_balancer_type              = "application"
  target_type                     = "instance"
  internal                        = false
  enable_deletion_protection      = false
  idle_timeout                    = 120
  healthcheck_healthy_threshold   = 2
  healthcheck_unhealthy_threshold = 2
  healthcheck_timeout             = 40
  healthcheck_interval            = 60
  action_type                     = "forward"
  healthCheck_path                = "/wp-login.php"
  matcher                         = "200-399"

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

  tags = {
    Environment = "production"
    Application = "myapp"
    ManagedBy   = "terraform"
  }
}

cluster = {
  create = true
  name   = "dev-ecs-cluster"
  region = "us-east-1"
  tags = {
    Environment = "dev"
    Project     = "wordpress-app"
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
  cloudwatch_log_group_kms_key_id        = ""
  cloudwatch_log_group_class             = "STANDARD"
  cloudwatch_log_group_tags              = { Environment = "dev" }
}
service = {
  wordpress = {
    create         = true
    create_service = true
    name           = "wordpress-service"
    desired_count  = 1
    launch_type    = "FARGATE"

    platform_version                   = "LATEST"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    wait_for_steady_state              = false

    assign_public_ip = false

    load_balancer = {
      wordpress_lb = {
        container_name = "wordpress"
        container_port = 80
      }
    }
    create_security_group          = true
    security_group_name            = "wordpress-sg"
    security_group_use_name_prefix = true
    security_group_description     = "ECS service SG"
    security_group_ingress_rules = {
      http = { cidr_ipv4 = "0.0.0.0/0", from_port = 80, to_port = 80, ip_protocol = "tcp" }
    }
    security_group_egress_rules = {
      all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
    }
    security_group_tags = { Environment = "dev" }


    tags = {
      Environment = "dev"
    }
  }
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
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    launch_type              = "FARGATE"

    task_execution_role_name = "ecsTaskExecutionRole"

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

        healthCheck = {
          command = ["CMD-SHELL",
          "curl -f http://localhost/wp-login.php || exit 1"]
          interval    = 30
          timeout     = 5
          retries     = 3
          startPeriod = 120
        }

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
      }
    }

    tags = {
      Environment = "dev"
    }
  }
}