variable "vpc" {
  description = "Configurations for VPC"
  type = object({
    vpc_name                = string
    vpc_cidr                = string
    environment             = string
    subnet_types            = map(string)
    public_subnet_cidrs     = list(string)
    private_subnet_cidrs    = list(string)
    azs                     = list(string)
    cidr_block              = string
    domain                  = string
    map_public_ip_on_launch = bool
    dns_host_name           = bool
    enable_dns_support      = bool
  })
}
# variable "load_balancer" {
#   description = "Configurations for load balancer"
#   type = object({
#     name                            = string
#     target_port                     = number
#     protocol                        = string
#     load_balancer_type              = string
#     target_type                     = string
#     internal                        = bool
#     enable_deletion_protection      = bool
#     idle_timeout                    = number
#     healthcheck_healthy_threshold   = number
#     healthcheck_unhealthy_threshold = number
#     healthcheck_timeout             = number
#     healthcheck_interval            = number
#     action_type                     = string
#     matcher                         = string
#     healthCheck_path                = string
#     listner_port                    = number

#     security_group_rules = optional(list(object({
#       type            = string # "ingress" or "egress"
#       description     = optional(string)
#       from_port       = number
#       to_port         = number
#       protocol        = string
#       cidr_blocks     = optional(list(string))
#       security_groups = optional(list(string))
#       self            = optional(bool, false)
#     })), [])

#     tags = optional(map(string), {})
#   })
# }

variable "load_balancer" {
  description = "Configurations for load balancer with support for multiple services"
  type = object({
    name                       = string
    load_balancer_type         = string
    internal                   = bool
    enable_deletion_protection = bool
    idle_timeout               = number

    # Security group rules for ALB
    security_group_rules = optional(list(object({
      type            = string # "ingress" or "egress"
      description     = optional(string)
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
      self            = optional(bool, false)
    })), [])

    # Target groups - one per service
    target_groups = map(object({
      name        = string
      port        = number
      protocol    = string
      target_type = optional(string, "ip")
      health_check = optional(object({ # ← Change from individual fields
        path                = optional(string)
        matcher             = optional(string)
        interval            = optional(number)
        healthy_threshold   = optional(number)
        unhealthy_threshold = optional(number)
        timeout             = optional(number)
      }))
    }))

    # Listeners
    listeners = map(object({
      port                = number
      protocol            = string
      target_group_key    = string # Key from target_groups map
      ssl_policy          = optional(string)
      certificate_arn     = optional(string)
      default_action_type = optional(string, "forward")

      rules = optional(map(object({
        priority         = number
        path_patterns    = list(string) # ["/nginx/*", "/api/*"]
        target_group_key = string
      })), {})
    }))

    tags = optional(map(string), {})
  })
}
variable "ec2_capacity" {
  description = "EC2 capacity configuration for ECS cluster (used only if launch_type = EC2)"
  type = object({
    instance_type                  = string
    desired_capacity               = number
    min_size                       = number
    max_size                       = number
    managed_termination_protection = string
    maximum_scaling_step_size      = number
    minimum_scaling_step_size      = number
    target_capacity                = number
    managed_scaling_status         = string
    sg_name                        = string
    security_group_rules = optional(list(object({
      type            = string
      description     = optional(string)
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
      self            = optional(bool, false)
    })), [])

    tags = optional(map(string), {})
  })
  default = null
}
variable "cluster" {
  description = "Configuration for ECS cluster and related resources"
  type = object({
    # Cluster basic
    create = bool
    name   = string
    region = string
    tags   = map(string)

    # Cluster configuration
    configuration = optional(object({
      managed_storage_configuration = optional(object({
        fargate_ephemeral_storage_kms_key_id = optional(string)
        kms_key_id                           = optional(string)
      }))
    }))
    setting = optional(list(object({
      name  = string
      value = string
    })))

    # CloudWatch Log Group
    create_cloudwatch_log_group            = optional(bool)
    cloudwatch_log_group_name              = optional(string)
    cloudwatch_log_group_retention_in_days = optional(number)
    cloudwatch_log_group_kms_key_id        = optional(string)
    cloudwatch_log_group_class             = optional(string)
    cloudwatch_log_group_tags              = optional(map(string))
  })
}
variable "service" {
  description = "Map of ECS services to create"
  type = map(object({
    # Module Control
    create_service                     = bool
    ignore_task_definition_changes     = optional(bool)
    name                               = string
    desired_count                      = optional(number)
    deployment_maximum_percent         = optional(number)
    deployment_minimum_healthy_percent = optional(number)
    force_new_deployment               = optional(bool)
    launch_type                        = optional(string)
    platform_version                   = optional(string)
    scheduling_strategy                = optional(string)
    propagate_tags                     = optional(string)
    service_tags                       = optional(map(string))
    triggers                           = optional(map(string))
    wait_for_steady_state              = optional(bool)
    enable_fault_injection             = optional(bool)

    # Networking
    assign_public_ip   = optional(bool)
    subnet_ids         = optional(list(string))
    security_group_ids = optional(list(string))

    # Load Balancer
    load_balancer = optional(object({
      container_name   = string
      container_port   = number
      elb_name         = optional(string)
      target_group_arn = optional(string)
    }))

    # Task Definition
    create_task_definition   = optional(bool)
    task_definition_arn      = optional(string)
    family                   = optional(string)
    cpu                      = optional(number)
    memory                   = optional(number)
    network_mode             = optional(string)
    requires_compatibilities = optional(list(string))

    track_latest = optional(bool)
    skip_destroy = optional(bool)

    # IAM
    task_exec_iam_role_arn  = optional(string)
    task_exec_iam_role_name = optional(string)
    enable_execute_command  = optional(bool)

    # Security Group
    create_security_group          = optional(bool)
    vpc_id                         = optional(string)
    security_group_name            = optional(string)
    security_group_use_name_prefix = optional(bool)
    security_group_description     = optional(string)
    security_group_ingress_rules   = optional(map(any))
    security_group_egress_rules    = optional(map(any))
    security_group_tags            = optional(map(string))
    cloudwatch_log_group_name      = optional(string)

    # Containers
    container_definitions = optional(any)

    # Volumes
    volume = optional(map(any))

    # ✅ Ephemeral storage
    ephemeral_storage = optional(object({
      size_in_gib = number
    }))

    tags = optional(map(string))
  }))
}

variable "task_definition" {
  description = "Configuration for the ECS task definition"
  type = map(object({
    # Core task definition settings
    create_task_definition   = optional(bool, true)
    cpu                      = optional(string)
    memory                   = optional(string)
    family                   = optional(string)
    network_mode             = optional(string, "awsvpc")
    requires_compatibilities = optional(list(string), ["FARGATE"])
    launch_type              = optional(string, "FARGATE")
    enable_fault_injection   = optional(bool, false)
    skip_destroy             = optional(bool, false)
    track_latest             = optional(bool, false)
    current_region           = optional(string)

    # Container definitions
    container_definitions = optional(map(object({
      create            = optional(bool, true)
      name              = optional(string)
      image             = string
      cpu               = optional(number)
      memory            = optional(number)
      memoryReservation = optional(number)
      essential         = optional(bool, true)
      command           = optional(list(string))
      entrypoint        = optional(list(string))
      environment       = optional(list(map(string)))
      portMappings = optional(list(object({
        containerPort = number
        hostPort      = optional(number)
        protocol      = optional(string)
      })))
      healthCheck = optional(object({
        command     = list(string)
        interval    = number
        timeout     = number
        retries     = number
        startPeriod = optional(number)
      }))

      # CloudWatch Logs Configuration
      enable_cloudwatch_logging              = optional(bool, false)
      create_cloudwatch_log_group            = optional(bool, false)
      cloudwatch_log_group_name              = optional(string)
      cloudwatch_log_group_use_name_prefix   = optional(bool, false)
      cloudwatch_log_group_class             = optional(string, "STANDARD")
      cloudwatch_log_group_retention_in_days = optional(number, 30)
      cloudwatch_log_group_kms_key_id        = optional(string)

      # Other log configurations
      logConfiguration = optional(any)
    })), {})

    # IAM role settings
    create_task_execution_role       = optional(bool, true)
    task_execution_role_name         = optional(string, "ecs-task-execution-role")
    task_execution_role_description  = optional(string, "ECS Task Execution Role")
    external_task_execution_role_arn = optional(string)
    task_execution_custom_policies   = optional(string)
    task_execution_role_tags         = optional(map(string), {})

    # Storage
    ephemeral_storage = optional(object({
      size_in_gib = number
    }))

    volumes = optional(map(object({
      configure_at_launch = optional(bool)
      host_path           = optional(string)
      name                = optional(string)
      efs_volume_configuration = optional(object({
        file_system_id          = string
        root_directory          = optional(string)
        transit_encryption      = optional(string)
        transit_encryption_port = optional(number)
        authorization_config = optional(object({
          access_point_id = string
          iam             = optional(string)
        }))
      }))
    })), {})

    # Tags
    tags      = optional(map(string), {})
    task_tags = optional(map(string), {})
  }))

  default = null
}
