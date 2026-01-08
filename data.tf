# data "aws_iam_policy_document" "task_role_assume" {
#   for_each = {
#     for key, config in var.task_definition :
#     key => config
#     if try(config.create_tasks_role, false)
#   }

#   statement {
#     sid     = "ECSTasksAssumeRole"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# data "aws_iam_policy_document" "task_role" {
#   for_each = {
#     for key, config in var.task_definition :
#     key => config
#     if try(config.create_tasks_role, false) && can(config.task_role_statements) && length(config.task_role_statements) > 0
#   }

#   dynamic "statement" {
#     for_each = each.value.task_role_statements

#     content {
#       sid           = try(statement.value.sid, null)
#       actions       = statement.value.actions
#       not_actions   = try(statement.value.not_actions, null)
#       effect        = try(statement.value.effect, "Allow")
#       resources     = statement.value.resources
#       not_resources = try(statement.value.not_resources, null)

#       dynamic "condition" {
#         for_each = can(statement.value.condition) && statement.value.condition != null ? statement.value.condition : []
#         content {
#           test     = condition.value.test
#           values   = condition.value.values
#           variable = condition.value.variable
#         }
#       }
#     }
#   }
# }