locals {
  ec2_services = [
    for name, svc in var.service : name
    if upper(svc.launch_type) == "EC2"
  ]

  enable_ec2_capacity = length(local.ec2_services) > 0

  # ---------------------------------------
  # Task definition defaults
  # ---------------------------------------
  default_task_definition = {
    create_task_definition           = true
    cpu                              = null
    memory                           = null
    family                           = null
    network_mode                     = "awsvpc"
    requires_compatibilities         = ["FARGATE"]
    launch_type                      = "FARGATE"
    enable_fault_injection           = false
    skip_destroy                     = false
    track_latest                     = false
    container_definitions            = {}
    create_task_execution_role       = true
    task_execution_role_name         = "ecs-task-execution-role"
    task_execution_role_description  = "ECS Task Execution Role"
    external_task_execution_role_arn = null
    ephemeral_storage                = null
    volumes                          = {}
    tags                             = {}
    task_tags                        = {}
  }

  task_definition_configs = {
    for name, cfg in var.task_definition :
    name => merge(
      local.default_task_definition,
      cfg,
      {
        container_definitions = lookup(cfg, "container_definitions", {})
      }
    )
  }

  # ---------------------------------------
  # ECS SERVICE NORMALIZATION (IMPORTANT)
  # ---------------------------------------
  # service_configs = {
  #   for name, svc in var.service :
  #   name => {
  #     is_fargate            = upper(svc.launch_type) == "FARGATE"
  #     create_service        = svc.create && svc.create_service
  #     create_security_group = svc.create && svc.create_security_group && svc.network_mode == "awsvpc"

  #     security_group_name = coalesce(
  #       svc.security_group_name,
  #       svc.name,
  #       "NotProvided"
  #     )

  #     network_configuration = {
  #       assign_public_ip = svc.assign_public_ip
  #       security_groups  = svc.security_group_ids
  #     }

  #     log_group_name = coalesce(
  #       svc.cloudwatch_log_group_name,
  #       "/aws/ecs/${svc.name}"
  #     )
  #   }
  # }
  service_configs = {
    for name, svc in var.service :
    name => {
      is_fargate            = upper(svc.launch_type) == "FARGATE"
      create_service        = svc.create && svc.create_service
      create_security_group = svc.create && svc.create_security_group && svc.network_mode == "awsvpc"

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
