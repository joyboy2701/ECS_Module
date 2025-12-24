locals {
  service        = var.service != null ? "/${var.service}" : ""
  name           = var.name != null ? "/${var.name}" : ""
  log_group_name = try(coalesce(var.cloudwatch_log_group_name, "/aws/ecs${local.service}${local.name}"), "")

  logConfiguration = merge(
    { for k, v in {
      logDriver = "awslogs",
      options = {
        awslogs-group         = try(aws_cloudwatch_log_group.this[0].name, ""),
        awslogs-stream-prefix = "ecs"
        awslogs-region        = "us-east-1"
      },
    } : k => v if var.create_cloudwatch_log_group },
    { for k, v in var.logConfiguration : k => v if v != null }
  )

  definition = {
    command           = var.command
    cpu               = var.cpu
    entrypoint        = var.entrypoint
    environment       = var.environment
    essential         = var.essential
    healthCheck       = var.healthCheck
    image             = var.image
    logConfiguration  = length(local.logConfiguration) > 0 ? local.logConfiguration : null
    memory            = var.memory
    memoryReservation = var.memoryReservation
    name              = var.name
    portMappings      = var.portMappings != null ? [for p in var.portMappings : { for k, v in p : k => v if v != null }] : null
  }

  container_definition = { for k, v in local.definition : k => v if v != null }
}


resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group && var.enable_cloudwatch_logging ? 1 : 0

  region = var.region

  name              = var.cloudwatch_log_group_use_name_prefix ? null : local.log_group_name
  name_prefix       = var.cloudwatch_log_group_use_name_prefix ? "${local.log_group_name}-" : null
  log_group_class   = var.cloudwatch_log_group_class
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}