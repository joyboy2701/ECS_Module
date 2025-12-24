locals {
  ec2_services = [
    for name, svc in var.service : name
    if upper(svc.launch_type) == "EC2"
  ]

  enable_ec2_capacity = length(local.ec2_services) > 0
}
