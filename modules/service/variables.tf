variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
  nullable    = false
}

variable "create_service" {
  description = "Determines whether service resource will be created (set to `false` in case you want to create task definition only)"
  type        = bool
  default     = true
  nullable    = false
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  nullable    = false
}

################################################################################
# Service
################################################################################

variable "ignore_task_definition_changes" {
  description = "Whether changes to service `task_definition` changes should be ignored"
  type        = bool
  default     = false
  nullable    = false
}

variable "alarms" {
  description = "Information about the CloudWatch alarms"
  type = object({
    alarm_names = list(string)
    enable      = optional(bool, true)
    rollback    = optional(bool, true)
  })
  default = null
}

variable "availability_zone_rebalancing" {
  description = "ECS automatically redistributes tasks within a service across Availability Zones (AZs) to mitigate the risk of impaired application availability due to underlying infrastructure failures and task lifecycle activities. The valid values are `ENABLED` and `DISABLED`. Defaults to `DISABLED`"
  type        = string
  default     = null
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategies to use for the service. Can be one or more"
  type = map(object({
    base              = optional(number)
    capacity_provider = string
    weight            = optional(number)
  }))
  default = null
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster where the resources will be provisioned"
  type        = string
  default     = ""
  nullable    = false
}

variable "deployment_circuit_breaker" {
  description = "Configuration block for deployment circuit breaker"
  type = object({
    enable   = bool
    rollback = bool
  })
  default = null
}

variable "deployment_configuration" {
  description = "Configuration block for deployment settings"
  type = object({
    strategy             = optional(string)
    bake_time_in_minutes = optional(string)
    canary_configuration = optional(object({
      canary_bake_time_in_minutes = optional(string)
      canary_percent              = optional(string)
    }))
    linear_configuration = optional(object({
      step_bake_time_in_minutes = optional(string)
      step_percent              = optional(string)
    }))
    lifecycle_hook = optional(map(object({
      hook_target_arn  = string
      role_arn         = string
      lifecycle_stages = list(string)
      hook_details     = optional(string)
    })))
  })
  default = null
}

variable "deployment_controller" {
  description = "Configuration block for deployment controller configuration"
  type = object({
    type = optional(string)
  })
  default = null
}

variable "deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the service's `desired_count`) of the number of running tasks that can be running in a service during a deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the service's `desired_count`) of the number of running tasks that must remain running and healthy in a service during a deployment"
  type        = number
  default     = 66
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = true
  nullable    = false
}

variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
  nullable    = false
}

variable "force_delete" {
  description = "Enable to delete a service even if it wasn't scaled down to zero tasks. It's only necessary to use this if the service uses the `REPLICA` scheduling strategy"
  type        = bool
  default     = null
}

variable "force_new_deployment" {
  description = "Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination, roll Fargate tasks onto a newer platform version, or immediately deploy `ordered_placement_strategy` and `placement_constraints` updates"
  type        = bool
  default     = true
  nullable    = false
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers"
  type        = number
  default     = null
}

variable "launch_type" {
  description = "Launch type on which to run your service. The valid values are `EC2`, `FARGATE`, and `EXTERNAL`. Defaults to `FARGATE`"
  type        = string
  default     = "FARGATE"
  nullable    = false
}

variable "load_balancer" {
  description = "Configuration block for load balancers"
  type = map(object({
    container_name   = string
    container_port   = number
    elb_name         = optional(string)
    target_group_arn = optional(string)
    advanced_configuration = optional(object({
      alternate_target_group_arn = string
      production_listener_rule   = string
      role_arn                   = string
      test_listener_rule         = optional(string)
    }))
  }))
  default = null
}

variable "name" {
  description = "Name of the service (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = null
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI (Fargate launch type only)"
  type        = bool
  default     = false
  nullable    = false
}

variable "security_group_ids" {
  description = "List of security groups to associate with the task or service"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "sigint_rollback" {
  description = "Whether to enable graceful termination of deployments using SIGINT signals. Only applicable when using ECS deployment controller and requires wait_for_steady_state = true. Default is false"
  type        = bool
  default     = null
}

variable "subnet_ids" {
  description = "List of subnets to associate with the task or service"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "vpc_id" {
  description = "The VPC ID where to deploy the task or service. If not provided, the VPC ID is derived from the subnets provided"
  type        = string
  default     = null
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence"
  type = map(object({
    field = optional(string)
    type  = string
  }))
  default = null
}
variable "task_definition_arn" {
  type = string
}

variable "placement_constraints" {
  description = "Configuration block for rules that are taken into consideration during task placement (up to max of 10). This is set at the service, see `task_definition_placement_constraints` for setting at the task definition"
  type = map(object({
    expression = optional(string)
    type       = string
  }))
  default = null
}

variable "platform_version" {
  description = "Platform version on which to run your service. Only applicable for `launch_type` set to `FARGATE`. Defaults to `LATEST`"
  type        = string
  default     = null
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION`"
  type        = string
  default     = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA`"
  type        = string
  default     = null
}

variable "service_connect_configuration" {
  description = "The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace"
  type = object({
    enabled = optional(bool, true)
    log_configuration = optional(object({
      log_driver = string
      options    = optional(map(string))
      secret_option = optional(list(object({
        name       = string
        value_from = string
      })))
    }))
    namespace = optional(string)
    service = optional(list(object({
      client_alias = optional(object({
        dns_name = optional(string)
        port     = number
        test_traffic_rules = optional(list(object({
          header = optional(object({
            name = string
            value = object({
              exact = string
            })
          }))
        })))
      }))
      discovery_name        = optional(string)
      ingress_port_override = optional(number)
      port_name             = string
      timeout = optional(object({
        idle_timeout_seconds        = optional(number)
        per_request_timeout_seconds = optional(number)
      }))
      tls = optional(object({
        issuer_cert_authority = object({
          aws_pca_authority_arn = string
        })
        kms_key  = optional(string)
        role_arn = optional(string)
      }))
    })))
  })
  default = null
}

variable "service_registries" {
  description = "Service discovery registries for the service"
  type = object({
    container_name = optional(string)
    container_port = optional(number)
    port           = optional(number)
    registry_arn   = string
  })
  default = null
}

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the service"
  type = object({
    create = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "triggers" {
  description = "Map of arbitrary keys and values that, when changed, will trigger an in-place update (redeployment). Useful with `timestamp()`"
  type        = map(string)
  default     = null
}

variable "volume_configuration" {
  description = "Configuration for a volume specified in the task definition as a volume that is configured at launch time"
  type = object({
    name = string
    managed_ebs_volume = object({
      encrypted        = optional(bool)
      file_system_type = optional(string)
      iops             = optional(number)
      kms_key_id       = optional(string)
      size_in_gb       = optional(number)
      snapshot_id      = optional(string)
      tag_specifications = optional(list(object({
        propagate_tags = optional(string, "TASK_DEFINITION")
        resource_type  = string
        tags           = optional(map(string))
      })))
      throughput  = optional(number)
      volume_type = optional(string)
    })
  })
  default = null
}

variable "vpc_lattice_configurations" {
  description = "The VPC Lattice configuration for your service that allows Lattice to connect, secure, and monitor your service across multiple accounts and VPCs"
  type = object({
    role_arn         = string
    target_group_arn = string
    port_name        = string
  })
  default = null
}

variable "wait_for_steady_state" {
  description = "If true, Terraform will wait for the service to reach a steady state before continuing. Default is `false`"
  type        = bool
  default     = null
}

variable "service_tags" {
  description = "A map of additional tags to add to the service"
  type        = map(string)
  default     = {}
  nullable    = false
}


################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Determines if a security group is created"
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name (`security_group_name`) is used as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Security group ingress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_egress_rules" {
  description = "Security group egress rules to add to the security group created"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(string)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
  nullable    = false
}
variable "network_mode" {
  description = "Network mode for the service (needed for awsvpc network configuration)"
  type        = string
  default     = "awsvpc"
}