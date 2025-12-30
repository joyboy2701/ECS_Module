output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_cluster.name
}

output "cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group created"
  value       = module.ecs_cluster.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group created"
  value       = module.ecs_cluster.cloudwatch_log_group_arn
}
output "lb_dns_name" {
  value = module.load_balancer.alb_dns_name
}
