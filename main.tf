module "vpc" {
  source                  = "./modules/vpc"
  vpc_name                = var.vpc.vpc_name
  vpc_cidr                = var.vpc.vpc_cidr
  environment             = var.vpc.environment
  subnet_types            = var.vpc.subnet_types
  cidr_block              = var.vpc.cidr_block
  public_subnet_cidrs     = var.vpc.public_subnet_cidrs
  private_subnet_cidrs    = var.vpc.private_subnet_cidrs
  azs                     = var.vpc.azs
  domain                  = var.vpc.domain
  map_public_ip_on_launch = var.vpc.map_public_ip_on_launch
  enable_dns_support      = var.vpc.enable_dns_support
  dns_host_name           = var.vpc.dns_host_name
}
module "ecs_ec2_capacity" {
  count = local.enable_ec2_capacity ? 1 : 0

  source                         = "./modules/ec2_capacity"
  cluster_name                   = module.ecs_cluster.name
  subnets                        = module.vpc.private_subnet_ids
  instance_type                  = var.ec2_capacity.instance_type
  desired_capacity               = var.ec2_capacity.desired_capacity
  min_size                       = var.ec2_capacity.min_size
  max_size                       = var.ec2_capacity.max_size
  ecs_ami_id                     = data.aws_ami.ecs.id
  managed_termination_protection = var.ec2_capacity.managed_termination_protection
  maximum_scaling_step_size      = var.ec2_capacity.maximum_scaling_step_size
  minimum_scaling_step_size      = var.ec2_capacity.minimum_scaling_step_size
  vpc_id                         = module.vpc.vpc_id
  sg_name                        = var.ec2_capacity.sg_name
  target_capacity                = var.ec2_capacity.target_capacity
  managed_scaling_status         = var.ec2_capacity.managed_scaling_status
  security_group_rules           = try(var.ec2_capacity.security_group_rules, [])
  tags                           = try(var.ec2_capacity.tags, {})

  depends_on = [module.ecs_cluster]
}

module "load_balancer" {
  source = "./modules/load-balancer"

  name                            = var.load_balancer.name
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.public_subnet_ids
  target_port                     = var.load_balancer.target_port
  protocol                        = var.load_balancer.protocol
  load_balancer_type              = var.load_balancer.load_balancer_type
  target_type                     = var.load_balancer.target_type
  internal                        = var.load_balancer.internal
  enable_deletion_protection      = var.load_balancer.enable_deletion_protection
  idle_timeout                    = var.load_balancer.idle_timeout
  healthcheck_healthy_threshold   = var.load_balancer.healthcheck_healthy_threshold
  healthcheck_unhealthy_threshold = var.load_balancer.healthcheck_unhealthy_threshold
  healthcheck_interval            = var.load_balancer.healthcheck_interval
  action_type                     = var.load_balancer.action_type
  healthcheck_healthy_timeout     = var.load_balancer.healthcheck_timeout
  healthCheck_path                = var.load_balancer.healthCheck_path
  matcher                         = var.load_balancer.matcher
  listner_port                    = var.load_balancer.listner_port

  security_group_rules = try(var.load_balancer.security_group_rules, [])
  tags                 = try(var.load_balancer.tags, {})
}


module "ecs_cluster" {
  source = "./modules/cluster"

  create                                 = true
  name                                   = var.cluster.name
  region                                 = var.cluster.region
  tags                                   = var.cluster.tags
  configuration                          = var.cluster.configuration
  setting                                = var.cluster.setting
  create_cloudwatch_log_group            = var.cluster.create_cloudwatch_log_group
  cloudwatch_log_group_name              = var.cluster.cloudwatch_log_group_name
  cloudwatch_log_group_retention_in_days = var.cluster.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = data.aws_kms_key.log_group_key.arn
  cloudwatch_log_group_class             = var.cluster.cloudwatch_log_group_class
  cloudwatch_log_group_tags              = var.cluster.cloudwatch_log_group_tags

}

module "ecs_service" {
  source = "./modules/service"

  for_each                           = var.service
  is_fargate                         = local.service_configs[each.key].is_fargate
  network_configuration              = local.service_configs[each.key].network_configuration
  create                             = each.value.create
  create_service                     = each.value.create_service
  ignore_task_definition_changes     = each.value.ignore_task_definition_changes
  cluster_arn                        = module.ecs_cluster.arn
  name                               = each.value.name
  desired_count                      = each.value.desired_count
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  force_new_deployment               = each.value.force_new_deployment
  launch_type                        = each.value.launch_type
  platform_version                   = each.value.platform_version
  scheduling_strategy                = each.value.scheduling_strategy
  propagate_tags                     = each.value.propagate_tags
  service_tags                       = each.value.service_tags
  triggers                           = each.value.triggers
  wait_for_steady_state              = each.value.wait_for_steady_state

  # Networking
  assign_public_ip = each.value.assign_public_ip
  subnet_ids       = module.vpc.private_subnet_ids
  vpc_id           = module.vpc.vpc_id

  create_security_group       = each.value.create_security_group
  security_group_name         = each.value.security_group_name
  security_group_egress_rules = each.value.security_group_egress_rules
  # security_group_ingress_rules = each.value.security_group_ingress_rules

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
  security_group_tags = each.value.security_group_tags

  # Load Balancer
  load_balancer = {
    for lb_name, lb_config in each.value.load_balancer :
    lb_name => {
      target_group_arn = module.load_balancer.target_group_arn
      container_name   = lb_config.container_name
      container_port   = lb_config.container_port
    }
  }

  task_definition_arn = module.task_definition[each.key].task_definition_arn

  tags = each.value.tags
}

module "task_definition" {
  for_each = local.task_definition_configs
  source   = "./modules/task-definition"

  create_task_definition   = each.value.create_task_definition
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  family                   = coalesce(each.value.family, each.key)
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  launch_type              = each.value.launch_type
  enable_fault_injection   = each.value.enable_fault_injection
  skip_destroy             = each.value.skip_destroy
  track_latest             = each.value.track_latest
  current_region           = data.aws_region.current.region

  container_definitions            = each.value.container_definitions
  create_task_execution_role       = each.value.create_task_execution_role
  task_execution_role_name         = each.value.task_execution_role_name
  task_execution_role_description  = each.value.task_execution_role_description
  external_task_execution_role_arn = each.value.external_task_execution_role_arn
  task_execution_custom_policies   = each.value.task_execution_custom_policies
  task_execution_role_tags         = each.value.task_execution_role_tags

  ephemeral_storage = each.value.ephemeral_storage
  volumes           = each.value.volumes

  tags      = each.value.tags
  task_tags = each.value.task_tags
}