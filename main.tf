module "vpc" {
  source                  = "./modules/vpc"
  vpc_name                = var.vpc.vpc_name
  vpc_cidr                = var.vpc.vpc_cidr
  cidr_block              = var.vpc.cidr_block
  public_subnet_cidrs     = var.vpc.public_subnet_cidrs
  private_subnet_cidrs    = var.vpc.private_subnet_cidrs
  domain                  = var.vpc.domain
  map_public_ip_on_launch = var.vpc.map_public_ip_on_launch
  enable_dns_support      = var.vpc.enable_dns_support
  dns_host_name           = var.vpc.dns_host_name
  tags                    = var.base_tags

}

module "ecs_cluster" {
  source = "./modules/cluster"

  create                                 = var.cluster.create
  name                                   = var.cluster.name
  tags                                   = merge(var.base_tags, var.cluster.tags)
  configuration                          = var.cluster.configuration
  setting                                = var.cluster.setting
  create_cloudwatch_log_group            = var.cluster.create_cloudwatch_log_group
  cloudwatch_log_group_name              = var.cluster.cloudwatch_log_group_name
  cloudwatch_log_group_retention_in_days = var.cluster.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cluster.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_class             = var.cluster.cloudwatch_log_group_class
  cloudwatch_log_group_tags              = merge(var.base_tags, var.cluster.cloudwatch_log_group_tags)
}
module "ecs_ec2_capacity" {
  count  = local.enable_ec2_capacity ? 1 : 0
  source = "./modules/ec2_capacity"

  create                                         = var.ecs_ec2_capacity.create
  name                                           = var.ecs_ec2_capacity.name
  cluster_name                                   = module.ecs_cluster.name
  use_name_prefix                                = var.ecs_ec2_capacity.use_name_prefix
  vpc_id                                         = module.vpc.vpc_id
  vpc_zone_identifier                            = module.vpc.private_subnet_ids
  security_group_rules                           = var.ecs_ec2_capacity.security_group_rules
  sg_name                                        = var.ecs_ec2_capacity.sg_name
  min_size                                       = var.ecs_ec2_capacity.min_size
  max_size                                       = var.ecs_ec2_capacity.max_size
  desired_capacity                               = var.ecs_ec2_capacity.desired_capacity
  desired_capacity_type                          = var.ecs_ec2_capacity.desired_capacity_type
  protect_from_scale_in                          = var.ecs_ec2_capacity.protect_from_scale_in
  health_check_type                              = var.ecs_ec2_capacity.health_check_type
  health_check_grace_period                      = var.ecs_ec2_capacity.health_check_grace_period
  create_launch_template                         = var.ecs_ec2_capacity.create_launch_template
  instance_type                                  = var.ecs_ec2_capacity.instance_type
  key_name                                       = var.ecs_ec2_capacity.key_name
  create_iam_instance_profile                    = var.ecs_ec2_capacity.create_iam_instance_profile
  iam_role_name                                  = var.ecs_ec2_capacity.iam_role_name
  iam_role_policies                              = var.ecs_ec2_capacity.iam_role_policies
  iam_role_use_name_prefix                       = var.ecs_ec2_capacity.iam_role_use_name_prefix
  iam_role_path                                  = var.ecs_ec2_capacity.iam_role_path
  iam_role_description                           = var.ecs_ec2_capacity.iam_role_description
  iam_role_permissions_boundary                  = var.ecs_ec2_capacity.iam_role_permissions_boundary
  iam_role_tags                                  = var.ecs_ec2_capacity.iam_role_tags
  iam_instance_profile_arn                       = var.ecs_ec2_capacity.iam_instance_profile_arn
  iam_instance_profile_name                      = var.ecs_ec2_capacity.iam_instance_profile_name
  capacity_rebalance                             = var.ecs_ec2_capacity.capacity_rebalance
  context                                        = var.ecs_ec2_capacity.context
  default_cooldown                               = var.ecs_ec2_capacity.default_cooldown
  default_instance_warmup                        = var.ecs_ec2_capacity.default_instance_warmup
  force_delete_warm_pool                         = var.ecs_ec2_capacity.force_delete_warm_pool
  force_delete                                   = var.ecs_ec2_capacity.force_delete
  enabled_metrics                                = var.ecs_ec2_capacity.enabled_metrics
  ignore_failed_scaling_activities               = var.ecs_ec2_capacity.ignore_failed_scaling_activities
  ignore_desired_capacity_changes                = var.ecs_ec2_capacity.ignore_desired_capacity_changes
  instance_maintenance_policy                    = var.ecs_ec2_capacity.instance_maintenance_policy
  instance_refresh                               = var.ecs_ec2_capacity.instance_refresh
  launch_template_id                             = var.ecs_ec2_capacity.launch_template_id
  launch_template_version                        = var.ecs_ec2_capacity.launch_template_version
  max_instance_lifetime                          = var.ecs_ec2_capacity.max_instance_lifetime
  metrics_granularity                            = var.ecs_ec2_capacity.metrics_granularity
  min_elb_capacity                               = var.ecs_ec2_capacity.min_elb_capacity
  placement_group                                = var.ecs_ec2_capacity.placement_group
  service_linked_role_arn                        = var.ecs_ec2_capacity.service_linked_role_arn
  suspended_processes                            = var.ecs_ec2_capacity.suspended_processes
  autoscaling_group_tags                         = var.ecs_ec2_capacity.autoscaling_group_tags
  autoscaling_group_tags_not_propagate_at_launch = var.ecs_ec2_capacity.autoscaling_group_tags_not_propagate_at_launch
  termination_policies                           = var.ecs_ec2_capacity.termination_policies
  wait_for_capacity_timeout                      = var.ecs_ec2_capacity.wait_for_capacity_timeout
  wait_for_elb_capacity                          = var.ecs_ec2_capacity.wait_for_elb_capacity
  warm_pool                                      = var.ecs_ec2_capacity.warm_pool
  timeouts                                       = var.ecs_ec2_capacity.timeouts
  use_mixed_instances_policy                     = var.ecs_ec2_capacity.use_mixed_instances_policy
  mixed_instances_policy                         = var.ecs_ec2_capacity.mixed_instances_policy
  initial_lifecycle_hooks                        = var.ecs_ec2_capacity.initial_lifecycle_hooks
  launch_template_name                           = var.ecs_ec2_capacity.launch_template_name
  launch_template_use_name_prefix                = var.ecs_ec2_capacity.launch_template_use_name_prefix
  launch_template_description                    = var.ecs_ec2_capacity.launch_template_description
  default_version                                = var.ecs_ec2_capacity.default_version
  update_default_version                         = var.ecs_ec2_capacity.update_default_version
  block_device_mappings                          = var.ecs_ec2_capacity.block_device_mappings
  capacity_reservation_specification             = var.ecs_ec2_capacity.capacity_reservation_specification
  cpu_options                                    = var.ecs_ec2_capacity.cpu_options
  credit_specification                           = var.ecs_ec2_capacity.credit_specification
  disable_api_stop                               = var.ecs_ec2_capacity.disable_api_stop
  disable_api_termination                        = var.ecs_ec2_capacity.disable_api_termination
  ebs_optimized                                  = var.ecs_ec2_capacity.ebs_optimized
  hibernation_options                            = var.ecs_ec2_capacity.hibernation_options
  instance_initiated_shutdown_behavior           = var.ecs_ec2_capacity.instance_initiated_shutdown_behavior
  instance_market_options                        = var.ecs_ec2_capacity.instance_market_options
  instance_requirements                          = var.ecs_ec2_capacity.instance_requirements
  kernel_id                                      = var.ecs_ec2_capacity.kernel_id
  license_specifications                         = var.ecs_ec2_capacity.license_specifications
  maintenance_options                            = var.ecs_ec2_capacity.maintenance_options
  metadata_options                               = var.ecs_ec2_capacity.metadata_options
  enable_monitoring                              = var.ecs_ec2_capacity.enable_monitoring
  network_interfaces                             = var.ecs_ec2_capacity.network_interfaces
  placement                                      = var.ecs_ec2_capacity.placement
  private_dns_name_options                       = var.ecs_ec2_capacity.private_dns_name_options
  ram_disk_id                                    = var.ecs_ec2_capacity.ram_disk_id
  security_groups                                = var.ecs_ec2_capacity.security_groups
  tag_specifications                             = var.ecs_ec2_capacity.tag_specifications
  user_data                                      = var.ecs_ec2_capacity.user_data
  instance_name                                  = var.ecs_ec2_capacity.instance_name
  tags                                           = var.ecs_ec2_capacity.tags
  launch_template_tags                           = var.ecs_ec2_capacity.launch_template_tags
  traffic_source_attachments                     = var.ecs_ec2_capacity.traffic_source_attachments
  schedules                                      = var.ecs_ec2_capacity.schedules
  scaling_policies                               = var.ecs_ec2_capacity.scaling_policies
}

module "load_balancer" {
  source = "./modules/load-balancer"

  name                       = var.load_balancer.name
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  load_balancer_type         = var.load_balancer.load_balancer_type
  internal                   = var.load_balancer.internal
  enable_deletion_protection = var.load_balancer.enable_deletion_protection
  idle_timeout               = var.load_balancer.idle_timeout
  target_groups              = var.load_balancer.target_groups
  listeners                  = var.load_balancer.listeners
  security_group_rules       = try(var.load_balancer.security_group_rules, [])
  tags                       = try(merge(var.base_tags, var.load_balancer.tags, {}))
}

module "ecs_service" {
  source = "./modules/service"

  for_each                           = var.service
  is_fargate                         = local.service_configs[each.key].is_fargate
  network_configuration              = local.service_configs[each.key].network_configuration
  create_service                     = each.value.create_service
  ignore_task_definition_changes     = each.value.ignore_task_definition_changes
  cluster_arn                        = module.ecs_cluster.arn
  name                               = each.value.name
  desired_count                      = each.value.desired_count
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  force_new_deployment               = each.value.force_new_deployment
  platform_version                   = each.value.platform_version
  scheduling_strategy                = each.value.scheduling_strategy
  propagate_tags                     = each.value.propagate_tags
  service_tags                       = merge(var.base_tags, each.value.service_tags)
  launch_type                        = var.launch_type
  triggers                           = each.value.triggers
  wait_for_steady_state              = each.value.wait_for_steady_state

  # Networking
  assign_public_ip = each.value.assign_public_ip
  subnet_ids       = module.vpc.private_subnet_ids
  vpc_id           = module.vpc.vpc_id

  create_security_group       = each.value.create_security_group
  security_group_name         = each.value.security_group_name
  security_group_egress_rules = each.value.security_group_egress_rules

  security_group_ingress_rules = merge(
    each.value.security_group_ingress_rules,
    {
      # Add referenced_security_group_id to specific rules
      lb_to_app = merge(
        each.value.security_group_ingress_rules.lb_to_app,
        {
          referenced_security_group_id = module.load_balancer.sg_id
        }
      ),
    }
  )
  security_group_tags = merge(var.base_tags, each.value.security_group_tags)
  load_balancer = {
    target_group_arn = module.load_balancer.target_group_arns[each.key]
    container_name   = each.value.load_balancer.container_name
    container_port   = each.value.load_balancer.container_port
  }
  task_definition_arn = module.task_definition[each.key].task_definition_arn

  tags = merge(var.base_tags, each.value.tags)
}

module "task_definition" {
  for_each = var.task_definition
  source   = "./modules/task-definition"

  create_task_definition           = each.value.create_task_definition
  cpu                              = each.value.cpu
  memory                           = each.value.memory
  family                           = coalesce(each.value.family, each.key)
  network_mode                     = each.value.network_mode
  requires_compatibilities         = [var.launch_type]
  launch_type                      = var.launch_type
  enable_fault_injection           = each.value.enable_fault_injection
  skip_destroy                     = each.value.skip_destroy
  track_latest                     = each.value.track_latest
  container_definitions            = each.value.container_definitions
  create_task_execution_role       = each.value.create_task_execution_role
  task_execution_role_name         = each.value.task_execution_role_name
  task_execution_role_description  = each.value.task_execution_role_description
  external_task_execution_role_arn = each.value.external_task_execution_role_arn
  task_execution_role_tags         = merge(var.base_tags, each.value.task_execution_role_tags)
  tasks_exec_iam_role_policies     = try(each.value.task_exec_role_policies)

  # Task Role settings (for containers)
  create_tasks_iam_role               = try(each.value.create_tasks_role)
  tasks_iam_role_name                 = try(each.value.task_role_name)
  tasks_iam_role_description          = try(each.value.task_role_description)
  tasks_iam_role_path                 = try(each.value.task_role_path)
  tasks_iam_role_max_session_duration = try(each.value.task_role_max_session_duration)
  tasks_iam_role_permissions_boundary = try(each.value.task_role_permissions_boundary)
  tasks_iam_role_tags                 = merge(var.base_tags, try(each.value.task_role_tags))
  tasks_iam_role_statements           = try(each.value.task_role_statements)

  # tasks_iam_role_policies = try(each.value.task_role_policies)

  # tasks_iam_role_assume_policy = each.value.tasks_iam_role_assume_policy
  # tasks_iam_role_policy_json   = each.value.tasks_iam_role_policy_json
  tasks_iam_role_arn           = try(each.value.external_task_role_arn)

  ephemeral_storage = each.value.ephemeral_storage
  volumes           = each.value.volumes

  tags      = merge(var.base_tags, each.value.tags)
  task_tags = merge(var.base_tags, each.value.task_tags)

}
