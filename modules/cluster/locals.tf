locals {
  log_group_name = try(coalesce(var.cloudwatch_log_group_name, "/aws/ecs/${var.name}"), "")
}