locals {
  ec2_services = [
    for name, svc in var.service : name
    if upper(svc.launch_type) == "EC2"
  ]

  enable_ec2_capacity = length(local.ec2_services) > 0
}


locals {
  # Default task definition configuration (single object)
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
    task_execution_custom_policies   = null
    task_execution_role_tags         = {}
    ephemeral_storage                = null
    volumes                          = {}
    tags                             = {}
    task_tags                        = {}
  }

  # Apply defaults PER task definition (map → map)
  task_definition_configs = {
    for key, cfg in var.task_definition :
    key => merge(
      local.default_task_definition,
      cfg,
      {
        # Always guarantee container_definitions is a map
        container_definitions = lookup(cfg, "container_definitions", {})
      }
    )
  }
}
