locals {
  is_fargate = var.launch_type == "FARGATE"

  effective_security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : local.create_security_group  ? aws_security_group.this[*].id : []

  network_configuration = {
    assign_public_ip = var.assign_public_ip
    security_groups  = local.effective_security_group_ids
    subnets          = var.subnet_ids
  }

  create_service        = var.create && var.create_service
  create_security_group = var.create && var.create_security_group && var.network_mode == "awsvpc"
  security_group_name   = coalesce(var.security_group_name, var.name, "NotProvided")
}
