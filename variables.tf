variable "vpc" {
  description = "Configurations for VPC"
  type = object({
    vpc_name                = string
    vpc_cidr                = string
    public_subnet_cidrs     = list(string)
    private_subnet_cidrs    = list(string)
    cidr_block              = string
    domain                  = string
    map_public_ip_on_launch = bool
    dns_host_name           = bool
    enable_dns_support      = bool
  })
}

variable "launch_type" {
  type = string
}
variable "base_tags" {
  type = map(string)
}
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

variable "ecs_ec2_capacity" {
  description = "Configuration for ECS EC2 capacity"
  type = object({
    cluster_name    = optional(string)
    create          = optional(bool, true)
    name            = string
    use_name_prefix = optional(bool)
    sg_name         = optional(string)
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

    availability_zones = optional(list(string), null)
    availability_zone_distribution = optional(object({
      capacity_distribution_strategy = optional(string)
    }), null)
    capacity_rebalance               = optional(bool, null)
    context                          = optional(string, null)
    default_cooldown                 = optional(number, null)
    default_instance_warmup          = optional(number, null)
    desired_capacity                 = optional(number, null)
    desired_capacity_type            = optional(string, null)
    enabled_metrics                  = optional(list(string), [])
    force_delete                     = optional(bool, null)
    force_delete_warm_pool           = optional(bool, null)
    health_check_grace_period        = optional(number, null)
    health_check_type                = optional(string, null)
    ignore_failed_scaling_activities = optional(bool, false)
    ignore_desired_capacity_changes  = optional(bool, false)
    initial_lifecycle_hooks = optional(list(object({
      default_result          = optional(string)
      heartbeat_timeout       = optional(number)
      lifecycle_transition    = string
      name                    = string
      notification_metadata   = optional(string)
      notification_target_arn = optional(string)
      role_arn                = optional(string)
    })), null)
    instance_maintenance_policy = optional(object({
      max_healthy_percentage = number
      min_healthy_percentage = number
    }), null)
    instance_refresh = optional(object({
      preferences = optional(object({
        alarm_specification = optional(object({
          alarms = optional(list(string))
        }))
        auto_rollback                = optional(bool)
        checkpoint_delay             = optional(number)
        checkpoint_percentages       = optional(list(number))
        instance_warmup              = optional(number)
        max_healthy_percentage       = optional(number)
        min_healthy_percentage       = optional(number)
        scale_in_protected_instances = optional(string)
        skip_matching                = optional(bool)
        standby_instances            = optional(string)
      }))
      strategy = string
      triggers = optional(list(string))
    }), null)
    launch_template_id         = optional(string, null)
    launch_template_version    = optional(string, null)
    max_instance_lifetime      = optional(number, null)
    max_size                   = optional(number, null)
    metrics_granularity        = optional(string, null)
    min_elb_capacity           = optional(number, null)
    min_size                   = optional(number, null)
    use_mixed_instances_policy = optional(bool, false)
    mixed_instances_policy = optional(object({
      instances_distribution = optional(object({
        on_demand_allocation_strategy            = optional(string)
        on_demand_base_capacity                  = optional(number)
        on_demand_percentage_above_base_capacity = optional(number)
        spot_allocation_strategy                 = optional(string)
        spot_instance_pools                      = optional(number)
        spot_max_price                           = optional(string)
      }))
      launch_template = object({
        override = optional(list(object({
          instance_requirements = optional(object({
            accelerator_count = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            accelerator_manufacturers = optional(list(string))
            accelerator_names         = optional(list(string))
            accelerator_total_memory_mib = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            allowed_instance_types = optional(list(string))
            baseline_ebs_bandwidth_mbps = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            burstable_performance                                   = optional(string)
            cpu_manufacturers                                       = optional(list(string))
            excluded_instance_types                                 = optional(list(string))
            instance_generations                                    = optional(list(string))
            local_storage                                           = optional(string)
            local_storage_types                                     = optional(list(string))
            max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)
            memory_gib_per_vcpu = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            memory_mib = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            network_bandwidth_gbps = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            network_interface_count = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            on_demand_max_price_percentage_over_lowest_price = optional(number)
            require_hibernate_support                        = optional(bool)
            spot_max_price_percentage_over_lowest_price      = optional(number)
            total_local_storage_gb = optional(object({
              max = optional(number)
              min = optional(number)
            }))
            vcpu_count = optional(object({
              max = optional(number)
              min = optional(number)
            }))
          }))
          instance_type = optional(string)
          launch_template_specification = optional(object({
            launch_template_id   = optional(string)
            launch_template_name = optional(string)
            version              = optional(string)
          }))
          weighted_capacity = optional(string)
        })))
      })
    }), null)
    placement_group                                = optional(string, null)
    protect_from_scale_in                          = optional(bool, false)
    service_linked_role_arn                        = optional(string, null)
    suspended_processes                            = optional(list(string), [])
    autoscaling_group_tags                         = optional(map(string), {})
    autoscaling_group_tags_not_propagate_at_launch = optional(list(string), [])
    instance_name                                  = optional(string, "")
    termination_policies                           = optional(list(string), [])
    vpc_zone_identifier                            = optional(list(string), null)
    wait_for_capacity_timeout                      = optional(string, null)
    wait_for_elb_capacity                          = optional(number, null)
    warm_pool = optional(object({
      instance_reuse_policy = optional(object({
        reuse_on_scale_in = optional(bool)
      }))
      max_group_prepared_capacity = optional(number)
      min_size                    = optional(number)
      pool_state                  = optional(string)
    }), null)
    timeouts = optional(object({
      delete = optional(string)
    }), null)

    # Launch Template Configuration
    create_launch_template = optional(bool, true)
    block_device_mappings = optional(list(object({
      device_name = optional(string)
      ebs = optional(object({
        delete_on_termination      = optional(bool)
        encrypted                  = optional(bool)
        iops                       = optional(number)
        kms_key_id                 = optional(string)
        snapshot_id                = optional(string)
        throughput                 = optional(number)
        volume_initialization_rate = optional(number)
        volume_size                = optional(number)
        volume_type                = optional(string)
      }))
      no_device    = optional(string)
      virtual_name = optional(string)
    })), null)
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string)
      capacity_reservation_target = optional(object({
        capacity_reservation_id                 = optional(string)
        capacity_reservation_resource_group_arn = optional(string)
      }))
    }), null)
    cpu_options = optional(object({
      amd_sev_snp      = optional(string)
      core_count       = optional(number)
      threads_per_core = optional(number)
    }), null)
    credit_specification = optional(object({
      cpu_credits = optional(string)
    }), null)
    default_version             = optional(string, null)
    launch_template_description = optional(string, null)
    disable_api_stop            = optional(bool, null)
    disable_api_termination     = optional(bool, null)
    ebs_optimized               = optional(bool, null)
    enclave_options = optional(object({
      enabled = optional(bool)
    }), null)
    hibernation_options = optional(object({
      configured = optional(bool)
    }), null)
    image_id                             = optional(string, null)
    instance_initiated_shutdown_behavior = optional(string, null)
    instance_market_options = optional(object({
      market_type = optional(string)
      spot_options = optional(object({
        block_duration_minutes         = optional(number)
        instance_interruption_behavior = optional(string)
        max_price                      = optional(string)
        spot_instance_type             = optional(string)
        valid_until                    = optional(string)
      }))
    }), null)
    instance_requirements = optional(object({
      accelerator_count = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      accelerator_manufacturers = optional(list(string))
      accelerator_names         = optional(list(string))
      accelerator_total_memory_mib = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      accelerator_types      = optional(list(string))
      allowed_instance_types = optional(list(string))
      bare_metal             = optional(string)
      baseline_ebs_bandwidth_mbps = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      burstable_performance                                   = optional(string)
      cpu_manufacturers                                       = optional(list(string))
      excluded_instance_types                                 = optional(list(string))
      instance_generations                                    = optional(list(string))
      local_storage                                           = optional(string)
      local_storage_types                                     = optional(list(string))
      max_spot_price_as_percentage_of_optimal_on_demand_price = optional(number)
      memory_gib_per_vcpu = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      memory_mib = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      network_bandwidth_gbps = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      network_interface_count = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      on_demand_max_price_percentage_over_lowest_price = optional(number)
      require_hibernate_support                        = optional(bool)
      spot_max_price_percentage_over_lowest_price      = optional(number)
      total_local_storage_gb = optional(object({
        max = optional(number)
        min = optional(number)
      }))
      vcpu_count = optional(object({
        max = optional(number)
        min = string
      }))
    }), null)
    instance_type = optional(string, null)
    kernel_id     = optional(string, null)
    key_name      = optional(string, null)
    license_specifications = optional(list(object({
      license_configuration_arn = string
    })), null)
    launch_template_name            = optional(string, "")
    launch_template_use_name_prefix = optional(bool, true)
    maintenance_options = optional(object({
      auto_recovery = optional(string)
    }), null)
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_protocol_ipv6          = optional(string)
      http_put_response_hop_limit = optional(number, 1)
      http_tokens                 = optional(string, "required")
      instance_metadata_tags      = optional(string)
      }), {
      http_endpoint               = "enabled"
      http_put_response_hop_limit = 1
      http_tokens                 = "required"
    })
    enable_monitoring = optional(bool, true)
    network_interfaces = optional(list(object({
      associate_carrier_ip_address = optional(bool)
      associate_public_ip_address  = optional(bool)
      connection_tracking_specification = optional(object({
        tcp_established_timeout = optional(number)
        udp_stream_timeout      = optional(number)
        udp_timeout             = optional(number)
      }))
      delete_on_termination = optional(bool)
      description           = optional(string)
      device_index          = optional(number)
      interface_type        = optional(string)
      ipv4_address_count    = optional(number)
      ipv4_addresses        = optional(list(string))
      ipv4_prefix_count     = optional(number)
      ipv4_prefixes         = optional(list(string))
      ipv6_address_count    = optional(number)
      ipv6_addresses        = optional(list(string))
      ipv6_prefix_count     = optional(number)
      ipv6_prefixes         = optional(list(string))
      network_card_index    = optional(number)
      network_interface_id  = optional(string)
      primary_ipv6          = optional(bool)
      private_ip_address    = optional(string)
      security_groups       = optional(list(string), [])
      subnet_id             = optional(string)
    })), null)
    placement = optional(object({
      affinity                = optional(string)
      availability_zone       = optional(string)
      group_id                = optional(string)
      group_name              = optional(string)
      host_id                 = optional(string)
      host_resource_group_arn = optional(string)
      partition_number        = optional(number)
      spread_domain           = optional(string)
      tenancy                 = optional(string)
    }), null)
    private_dns_name_options = optional(object({
      enable_resource_name_dns_aaaa_record = optional(bool)
      enable_resource_name_dns_a_record    = optional(bool)
      hostname_type                        = optional(string)
    }), null)
    ram_disk_id = optional(string, null)
    tag_specifications = optional(list(object({
      resource_type = optional(string)
      tags          = optional(map(string), {})
    })), null)
    update_default_version = optional(bool, null)
    user_data              = optional(string, null)
    security_groups        = optional(list(string), [])
    launch_template_tags   = optional(map(string), {})

    # Traffic Source Attachments
    traffic_source_attachments = optional(map(object({
      traffic_source_identifier = string
      traffic_source_type       = optional(string, "elbv2")
    })), null)

    # Schedules
    schedules = optional(map(object({
      desired_capacity = optional(number)
      end_time         = optional(string)
      max_size         = optional(number)
      min_size         = optional(number)
      recurrence       = optional(string)
      start_time       = optional(string)
      time_zone        = optional(string)
    })), null)

    # Scaling Policies
    scaling_policies = optional(map(object({
      adjustment_type           = optional(string)
      cooldown                  = optional(number)
      enabled                   = optional(bool)
      estimated_instance_warmup = optional(number)
      metric_aggregation_type   = optional(string)
      min_adjustment_magnitude  = optional(number)
      name                      = optional(string)
      policy_type               = optional(string)
      predictive_scaling_configuration = optional(object({
        max_capacity_breach_behavior = optional(string)
        max_capacity_buffer          = optional(number)
        metric_specification = object({
          customized_capacity_metric_specification = optional(object({
            metric_data_queries = optional(list(object({
              expression = optional(string)
              id         = string
              label      = optional(string)
              metric_stat = optional(object({
                metric = object({
                  dimensions = optional(list(object({
                    name  = string
                    value = string
                  })))
                  metric_name = string
                  namespace   = string
                })
                stat = string
                unit = optional(string)
              }))
              return_data = optional(bool)
            })))
          }))
          customized_load_metric_specification = optional(object({
            metric_data_queries = optional(list(object({
              expression = optional(string)
              id         = string
              label      = optional(string)
              metric_stat = optional(object({
                metric = object({
                  dimensions = optional(list(object({
                    name  = string
                    value = string
                  })))
                  metric_name = string
                  namespace   = string
                })
                stat = string
                unit = optional(string)
              }))
              return_data = optional(bool)
            })))
          }))
          customized_scaling_metric_specification = optional(object({
            metric_data_queries = optional(list(object({
              expression = optional(string)
              id         = string
              label      = optional(string)
              metric_stat = optional(object({
                metric = object({
                  dimensions = optional(list(object({
                    name  = string
                    value = string
                  })))
                  metric_name = string
                  namespace   = string
                })
                stat = string
                unit = optional(string)
              }))
              return_data = optional(bool)
            })))
          }))
          predefined_load_metric_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          predefined_metric_pair_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          predefined_scaling_metric_specification = optional(object({
            predefined_metric_type = string
            resource_label         = optional(string)
          }))
          target_value = optional(number)
        })
        mode                   = optional(string)
        scheduling_buffer_time = optional(number)
      }))
      scaling_adjustment = optional(number)
      step_adjustment = optional(list(object({
        metric_interval_lower_bound = optional(number)
        metric_interval_upper_bound = optional(number)
        scaling_adjustment          = number
      })))
      target_tracking_configuration = optional(object({
        customized_metric_specification = optional(object({
          metric_dimension = optional(list(object({
            name  = string
            value = string
          })))
          metric_name = optional(string)
          metrics = optional(list(object({
            expression = optional(string)
            id         = string
            label      = optional(string)
            metric_stat = optional(object({
              metric = object({
                dimensions = optional(list(object({
                  name  = string
                  value = string
                })))
                metric_name = string
                namespace   = string
              })
              period = optional(number)
              stat   = string
              unit   = optional(string)
            }))
            return_data = optional(bool)
          })))
          namespace = optional(string)
          period    = optional(number)
          statistic = optional(string)
          unit      = optional(string)
        }))
        disable_scale_in = optional(bool)
        predefined_metric_specification = optional(object({
          predefined_metric_type = string
          resource_label         = optional(string)
        }))
        target_value = number
      }))
    })), null)

    # IAM Configuration
    create_iam_instance_profile   = optional(bool, false)
    iam_instance_profile_arn      = optional(string, null)
    iam_instance_profile_name     = optional(string, null)
    iam_role_name                 = optional(string, null)
    iam_role_use_name_prefix      = optional(bool, true)
    iam_role_path                 = optional(string, null)
    iam_role_description          = optional(string, null)
    iam_role_permissions_boundary = optional(string, null)
    iam_role_policies             = optional(map(string), {})
    iam_role_tags                 = optional(map(string), {})
  })
  default = null
}

variable "cluster" {
  description = "Configuration for ECS cluster and related resources"
  type = object({
    # Cluster basic
    create = bool
    name   = string
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
    create_task_definition = optional(bool)
    task_definition_arn    = optional(string)
    family                 = optional(string)
    cpu                    = optional(number)
    memory                 = optional(number)
    network_mode           = optional(string)

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
    create_task_definition = optional(bool, true)
    cpu                    = optional(string)
    memory                 = optional(string)
    family                 = optional(string)
    network_mode           = optional(string, "awsvpc")
    enable_fault_injection = optional(bool, false)
    skip_destroy           = optional(bool, false)
    track_latest           = optional(bool, false)
    current_region         = optional(string)

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

      secrets = optional(list(object({
        name      = string
        valueFrom = string
      })), [])

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
    task_execution_role_tags         = optional(map(string), {})
    task_exec_role_policies          = optional(map(string), {})

    # Task IAM Role settings (for containers)
    create_tasks_role              = optional(bool, false)
    task_role_name                 = optional(string)
    task_role_use_name_prefix      = optional(bool, false)
    task_role_description          = optional(string, "IAM role for ECS tasks")
    task_role_path                 = optional(string, "/")
    task_role_max_session_duration = optional(number, 3600)
    task_role_permissions_boundary = optional(string)
    external_task_role_arn         = optional(string)
    task_role_tags                 = optional(map(string), {})

    task_role_statements = optional(list(object({
      sid           = optional(string)
      actions       = list(string)
      not_actions   = optional(list(string))
      effect        = optional(string, "Allow")
      resources     = list(string)
      not_resources = optional(list(string))
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      condition = optional(list(object({
        test     = string
        values   = list(string)
        variable = string
      })))
    })), [])

    task_role_policies = optional(map(string), {})

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