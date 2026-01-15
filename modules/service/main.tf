locals {
  service_configs = {
    is_fargate            = upper(var.launch_type) == "FARGATE"
    create_security_group = var.network_mode == "awsvpc"

    security_group_name = coalesce(
      var.security_group_name,
      var.name,
      "NotProvided"
    )
    # Only set network_configuration for Fargate or awsvpc tasks
    network_configuration = (upper(var.launch_type) == "FARGATE" || var.network_mode == "awsvpc") ? {
      assign_public_ip = var.assign_public_ip
      security_groups  = var.security_group_ids
    } : null

    log_group_name = coalesce(
      "/aws/ecs/${var.name}"
    )
  }
}
resource "aws_ecs_service" "this" {
  count = !var.ignore_task_definition_changes ? 1 : 0

  dynamic "alarms" {
    for_each = var.alarms != null ? [var.alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }
  

  availability_zone_rebalancing = var.availability_zone_rebalancing

  cluster = var.cluster_arn

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  force_new_deployment               = var.force_new_deployment
  launch_type                        = var.capacity_provider_strategy != null ? null : var.launch_type
  platform_version                   = local.service_configs.is_fargate ? var.platform_version : null

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = try(load_balancer.value.elb_name, null)
      target_group_arn = try(load_balancer.value.target_group_arn, null)
    }
  }

  name = var.name

  dynamic "network_configuration" {
    for_each = (var.launch_type == "FARGATE" || var.network_mode == "awsvpc") && local.service_configs.network_configuration != null ? [local.service_configs.network_configuration] : []

    content {
      assign_public_ip = network_configuration.value.assign_public_ip
      security_groups = concat(
        var.security_group_ids != null ? var.security_group_ids : [],
        var.create_security_group && length(aws_security_group.this) > 0 ? [aws_security_group.this[0].id] : []
      )
      subnets = var.subnet_ids
    }
  }

  propagate_tags      = var.propagate_tags
  scheduling_strategy = var.scheduling_strategy

  tags            = merge(var.tags, var.service_tags)
  task_definition = var.task_definition_arn
  triggers        = var.triggers

  wait_for_steady_state = var.wait_for_steady_state
  lifecycle {
    ignore_changes = [
      desired_count # Always ignored
    ]
  }
}
# Security Group

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = var.security_group_use_name_prefix ? null : var.security_group_name
  name_prefix = var.security_group_use_name_prefix ? "${var.security_group_name}-" : null
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { "Name" = var.security_group_name },
    var.security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for k, v in var.security_group_ingress_rules : k => v if var.security_group_ingress_rules != null && var.create_security_group }

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
    { "Name" = coalesce(each.value.name, "${var.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = try(coalesce(each.value.to_port, each.value.from_port), null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for k, v in var.security_group_egress_rules : k => v if var.security_group_egress_rules != null && var.create_security_group }

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
    { "Name" = coalesce(each.value.name, "${var.security_group_name}-${each.key}") },
    each.value.tags
  )
  to_port = each.value.to_port
}