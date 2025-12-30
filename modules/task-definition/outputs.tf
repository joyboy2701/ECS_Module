output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].arn : null
}
output "task_definition_family" {
  description = "Family of the task definition"
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].family : null
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = var.create_task_definition ? aws_ecs_task_definition.this[0].revision : null
}

output "task_execution_role_arn" {
  description = "ARN of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role[0].arn
}

output "task_execution_role_name" {
  description = "Name of the task execution role"
  value       = var.create_task_execution_role ? aws_iam_role.ecs_task_execution_role[0].name : split("/", var.external_task_execution_role_arn)[1]
}

output "log_group_arns" {
  description = "ARNs of CloudWatch log groups created"
  value = {
    for key, container in var.container_definitions : key =>
    try(aws_cloudwatch_log_group.container_logs[key].arn, null)
    if var.create_task_definition &&
    try(container.create, true) &&
    container.enable_cloudwatch_logging &&
    container.create_cloudwatch_log_group
  }
}