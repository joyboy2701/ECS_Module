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
ec2_capacity = {
  instance_type                  = "t2.medium"
  desired_capacity               = 1
  min_size                       = 1
  max_size                       = 3
  managed_termination_protection = "DISABLED"
  maximum_scaling_step_size      = 1000
  minimum_scaling_step_size      = 1
  target_capacity                = 100
  managed_scaling_status         = "ENABLED"
  sg_name                        = "wordpress-ec2-capacity-sg"
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

load_balancer = {
  name                            = "my-alb"
  target_port                     = 80
  protocol                        = "HTTP"
  load_balancer_type              = "application"
  target_type                     = "ip"
  internal                        = false
  enable_deletion_protection      = false
  idle_timeout                    = 60
  healthcheck_healthy_threshold   = 2
  healthcheck_unhealthy_threshold = 2
  healthcheck_timeout             = 5
  healthcheck_interval            = 30
  action_type                     = "forward"
  healthCheck_path                = "/"
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

  configuration = {
    managed_storage_configuration = {
      kms_key_id = "arn:aws:kms:us-east-1:569023477847:key/d33f023a-8e2f-47a5-8fa7-22adf1f65d13"
    }
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
    create                             = true
    create_service                     = true
    name                               = "wordpress-service"
    desired_count                      = 1
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 50
    launch_type                        = "FARGATE"
    platform_version                   = "LATEST"
    scheduling_strategy                = "REPLICA"
    propagate_tags                     = "SERVICE"
    service_tags                       = { Environment = "dev" }
    triggers                           = {}
    wait_for_steady_state              = false
    enable_fault_injection             = false

    assign_public_ip = false

    load_balancer = {
      wordpress_lb = {
        container_name = "wordpress"
        container_port = 80
      }
    }

    create_task_definition   = true
    family                   = "wordpress"
    cpu                      = 1024
    memory                   = 2048
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]

    task_exec_iam_role_name = "ecsTaskExecutionRole"
    enable_execute_command  = true

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

    container_definitions = {
      wordpress = {
        create       = true
        image        = "wordpress:latest"
        cpu          = 256
        memory       = 512
        essential    = true
        portMappings = [{ containerPort = 80, protocol = "tcp" }]
        environment = [{ name = "WORDPRESS_DB_HOST", value = "127.0.0.1:3306" },
          { name = "WORDPRESS_DB_USER", value = "wpuser" },
          { name = "WORDPRESS_DB_PASSWORD", value = "wppassword" },
        { name = "WORDPRESS_DB_NAME", value = "wordpress" }]
        create_cloudwatch_log_group = false

      }
      mysql = {
        create       = true
        image        = "mysql:8.0"
        cpu          = 256
        memory       = 512
        essential    = true
        portMappings = [{ containerPort = 3306, protocol = "tcp" }]
        environment = [
          { name = "MYSQL_DATABASE", value = "wordpress" },
          { name = "MYSQL_USER", value = "wpuser" },
          { name = "MYSQL_PASSWORD", value = "wppassword" },
          { name = "MYSQL_ROOT_PASSWORD", value = "rootpassword" }
        ]

        create_cloudwatch_log_group = false
      }
    }
    ephemeral_storage = { size_in_gib = 21 }

    tags = { Environment = "dev" }
  }
}