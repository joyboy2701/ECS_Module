locals {
  ec2_services = [
    for name, svc in var.service : name
    if upper(svc.launch_type) == "EC2"
  ]

  enable_ec2_capacity = length(local.ec2_services) > 0

  task_definition_configs = {
    for name, cfg in var.task_definition :
    name => merge(
      cfg,
      {
        container_definitions = lookup(cfg, "container_definitions", {})
      }
    )
  }
  service_configs = {
    for name, svc in var.service :
    name => {
      is_fargate            = upper(svc.launch_type) == "FARGATE"
      create_service        = svc.create_service
      create_security_group = svc.create_security_group && svc.network_mode == "awsvpc"

      security_group_name = coalesce(
        svc.security_group_name,
        svc.name,
        "NotProvided"
      )
      # Only set network_configuration for Fargate or awsvpc tasks
      network_configuration = (upper(svc.launch_type) == "FARGATE" || svc.network_mode == "awsvpc") ? {
        assign_public_ip = svc.assign_public_ip
        security_groups  = svc.security_group_ids
      } : null

      log_group_name = coalesce(
        svc.cloudwatch_log_group_name,
        "/aws/ecs/${svc.name}"
      )
    }
  }
}