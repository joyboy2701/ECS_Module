# Create all CloudWatch Log Groups first
resource "aws_cloudwatch_log_group" "container_logs" {
  for_each = {
    for key, container in var.container_definitions : key => container
    if var.create_task_definition &&
    try(container.create, true) &&
    container.enable_cloudwatch_logging &&
    container.create_cloudwatch_log_group
  }

  name              = each.value.cloudwatch_log_group_use_name_prefix ? null : each.value.cloudwatch_log_group_name
  name_prefix       = each.value.cloudwatch_log_group_use_name_prefix ? "${each.value.cloudwatch_log_group_name}-" : null
  retention_in_days = each.value.cloudwatch_log_group_retention_in_days
  kms_key_id        = each.value.cloudwatch_log_group_kms_key_id
  log_group_class   = each.value.cloudwatch_log_group_class

  tags = merge(var.tags, {
    Container = each.key
    Purpose   = "ECS-Logs"
  })
}

# Task Execution IAM Role
resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.create_task_execution_role ? 1 : 0

  name        = var.task_execution_role_name
  description = var.task_execution_role_description

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

  tags = merge(var.tags, var.task_execution_role_tags)
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  count = var.create_task_execution_role ? 1 : 0

  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: Custom execution role policies
resource "aws_iam_policy" "ecs_task_execution_custom" {
  count = var.create_task_execution_role && var.task_execution_custom_policies != null ? 1 : 0

  name        = "${var.task_execution_role_name}-custom"
  description = "Custom policies for ECS task execution"
  policy      = var.task_execution_custom_policies

  tags = merge(var.tags, var.task_execution_role_tags)
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_custom" {
  count = var.create_task_execution_role && var.task_execution_custom_policies != null ? 1 : 0

  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = aws_iam_policy.ecs_task_execution_custom[0].arn
}



# Single resource for task definition with clean inline container definitions
resource "aws_ecs_task_definition" "this" {
  count         = var.create_task_definition ? 1 : 0
  task_role_arn = "arn:aws:iam::569023477847:role/ecs-exec-task-role"

  container_definitions = jsonencode([
    for key, container in var.container_definitions :
    merge(
      {
        name              = coalesce(container.name, key)
        image             = container.image
        cpu               = container.cpu
        memory            = container.memory
        memoryReservation = container.memoryReservation
        essential         = try(container.essential, true)
        command           = container.command
        entrypoint        = container.entrypoint

        environment  = container.environment
        portMappings = coalesce(try(container.portMappings, container.port_mappings), [])

        healthCheck = container.healthCheck
      },
      # Add logConfiguration only if needed
      container.enable_cloudwatch_logging ? {
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = container.create_cloudwatch_log_group ? (container.cloudwatch_log_group_use_name_prefix ? "${container.cloudwatch_log_group_name}-" : container.cloudwatch_log_group_name) : container.cloudwatch_log_group_name
            "awslogs-region"        = var.current_region
            "awslogs-stream-prefix" = "ecs"
          }
        }
        } : container.logConfiguration != null ? {
        logConfiguration = container.logConfiguration
      } : {}
    )
    if var.create_task_definition && try(container.create, true)
  ])

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

  execution_role_arn = aws_iam_role.ecs_task_execution_role[0].arn
  family             = var.family

  memory       = var.memory
  network_mode = var.network_mode

  requires_compatibilities = var.requires_compatibilities

  skip_destroy = var.skip_destroy
  track_latest = var.track_latest

  dynamic "volume" {
    for_each = var.volumes != null ? var.volumes : {}

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