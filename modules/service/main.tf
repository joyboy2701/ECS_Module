locals {

  is_fargate = var.launch_type == "FARGATE"

  network_configuration = {
    assign_public_ip = var.assign_public_ip
    security_groups  = flatten(concat([try(aws_security_group.this[0].id, [])], var.security_group_ids))
    subnets          = var.subnet_ids
  }

  create_service = var.create && var.create_service
}

resource "aws_ecs_service" "this" {
  count = local.create_service && !var.ignore_task_definition_changes ? 1 : 0

  dynamic "alarms" {
    for_each = var.alarms != null ? [var.alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  availability_zone_rebalancing = var.availability_zone_rebalancing

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy != null ? var.capacity_provider_strategy : {}

    content {
      base              = capacity_provider_strategy.value.base
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
    }
  }

  cluster = var.cluster_arn

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  force_new_deployment               = var.force_new_deployment
  launch_type                        = var.capacity_provider_strategy != null ? null : var.launch_type
  platform_version                   = local.is_fargate ? var.platform_version : null

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? var.load_balancer : {}

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = load_balancer.value.elb_name
      target_group_arn = load_balancer.value.target_group_arn

      dynamic "advanced_configuration" {
        for_each = load_balancer.value.advanced_configuration != null ? [load_balancer.value.advanced_configuration] : []

        content {
          alternate_target_group_arn = advanced_configuration.value.alternate_target_group_arn
          production_listener_rule   = advanced_configuration.value.production_listener_rule
          role_arn                   = advanced_configuration.value.role_arn
          test_listener_rule         = advanced_configuration.value.test_listener_rule
        }
      }
    }
  }

  name = var.name

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [local.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups  = network_configuration.value.security_groups
      subnets          = network_configuration.value.subnets
    }
  }
  propagate_tags      = var.propagate_tags
  scheduling_strategy = var.scheduling_strategy

  tags            = merge(var.tags, var.service_tags)
  task_definition = local.task_definition
  triggers        = var.triggers


  wait_for_steady_state = var.wait_for_steady_state
  lifecycle {
    ignore_changes = [
      desired_count, # Always ignored
    ]
  }
}

module "container_definition" {
  source = "../container-definition"

  for_each = { for k, v in var.container_definitions : k => v if local.create_task_definition && v.create }

  enable_execute_command  = var.enable_execute_command
  operating_system_family = var.runtime_platform.operating_system_family

  command = each.value.command
  cpu     = each.value.cpu

  entrypoint  = each.value.entrypoint
  environment = each.value.environment
  essential   = each.value.essential

  healthCheck       = each.value.healthCheck
  image             = each.value.image
  logConfiguration  = each.value.logConfiguration
  memory            = each.value.memory
  memoryReservation = each.value.memoryReservation
  name              = coalesce(each.value.name, each.key)
  portMappings      = each.value.portMappings

  service                                = var.name
  enable_cloudwatch_logging              = each.value.enable_cloudwatch_logging
  create_cloudwatch_log_group            = each.value.create_cloudwatch_log_group
  cloudwatch_log_group_name              = each.value.cloudwatch_log_group_name
  cloudwatch_log_group_use_name_prefix   = each.value.cloudwatch_log_group_use_name_prefix
  cloudwatch_log_group_class             = each.value.cloudwatch_log_group_class
  cloudwatch_log_group_retention_in_days = each.value.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = each.value.cloudwatch_log_group_kms_key_id

  tags = var.tags
}

locals {
  create_task_definition = var.create && var.create_task_definition
  task_definition        = local.create_task_definition ? aws_ecs_task_definition.this[0].arn : var.task_definition_arn
}

resource "aws_ecs_task_definition" "this" {
  count = local.create_task_definition ? 1 : 0
  # Convert map of maps to array of maps before JSON encoding
  container_definitions  = jsonencode([for k, v in module.container_definition : v.container_definition])
  cpu                    = var.cpu
  enable_fault_injection = var.enable_fault_injection

  dynamic "ephemeral_storage" {
    for_each = (
      var.launch_type == "FARGATE" && var.ephemeral_storage != null
    ) ? [var.ephemeral_storage] : []

    content {
      size_in_gib = ephemeral_storage.value.size_in_gib
    }
  }

  execution_role_arn = try(aws_iam_role.ecs_task_execution_role.arn, var.task_exec_iam_role_arn)
  family             = coalesce(var.family, var.name)

  memory       = var.memory
  network_mode = var.network_mode

  requires_compatibilities = var.requires_compatibilities

  skip_destroy = var.skip_destroy
  track_latest = var.track_latest

  dynamic "volume" {
    for_each = var.volume != null ? var.volume : {}

    content {
      configure_at_launch = volume.value.configure_at_launch


      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []

        content {
          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []

            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }

          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port
        }
      }

      host_path = volume.value.host_path
      name      = coalesce(volume.value.name, volume.key)
    }
  }

  tags = merge(var.tags, var.task_tags)


  lifecycle {
    create_before_destroy = true
  }
}

# Task Execution - IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.task_exec_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Security Group

locals {
  create_security_group = var.create && var.create_security_group && var.network_mode == "awsvpc"
  security_group_name   = coalesce(var.security_group_name, var.name, "NotProvided")
}

resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : local.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${local.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = local.security_group_name },
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in var.security_group_ingress_rules : k => v if var.security_group_ingress_rules != null && local.create_security_group }



  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in var.security_group_egress_rules : k => v if var.security_group_egress_rules != null && local.create_security_group }

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = try(coalesce(each.value.from_port, each.value.to_port), null)
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id
  security_group_id            = aws_security_group.this[0].id
  tags = merge(
    var.tags,
    var.security_group_tags,
    { "Name" = coalesce(each.value.name, "${local.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}