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
  cloudwatch_log_group_kms_key_id        = "d33f023a-8e2f-47a5-8fa7-22adf1f65d13"
}

load_balancer = {
  name                       = "my-alb"
  target_port                = 80
  protocol                   = "HTTP"
  listner_port               = 80
  load_balancer_type         = "application"
  target_type                = "ip"
  internal                   = false
  enable_deletion_protection = false
  idle_timeout               = 120
  action_type                = "forward"

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
      type        = "ingress"
      description = "HTTP from internet"
      from_port   = 8080
      to_port     = 8080
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
    },
    nginx = {
      name        = "nginx-tg"
      port        = 8080
      protocol    = "HTTP"
      target_type = "ip"
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
          path_patterns    = ["/nginx"]
          target_group_key = "nginx"
        }
      }

    },
    nginx = {
      port             = 8080
      protocol         = "HTTP"
      target_group_key = "nginx"
    }
  }

  tags = {
    Environment = "production"
    Application = "myapp"
    ManagedBy   = "terraform"
  }
}

service = {
  wordpress = {
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
    security_group_tags = { Environment = "dev" }


    tags = {
      Environment = "dev"
    }
  }
  nginx = {
    create_service = true
    name           = "nginx-service"
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
      }
    }

    tags = {
      Environment = "dev"
    }
  }
  nginx = {
    create_task_definition   = true
    family                   = "nginx"
    cpu                      = 1024
    memory                   = 2048
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    launch_type              = "FARGATE"

    task_execution_role_name = "ecsTaskExecutionRole_nginx"

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
        # command = [
        #   "sh",
        #   "-c",
        #   "sed -i 's/listen       80;/listen       8080;/' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
        # ]
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

    tags = {
      Environment = "dev"
    }
  }
}