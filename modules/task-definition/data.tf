data "aws_region" "current" {}
data "aws_iam_policy_document" "task_role_assume" {
  count = try(var.create_tasks_iam_role, false) ? 1 : 0

  statement {
    sid     = "ECSTasksAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_role" {
  count = try(var.create_tasks_iam_role, false) ? 1 : 0


  dynamic "statement" {
    for_each = var.tasks_iam_role_statements

    content {
      sid           = try(statement.value.sid, null)
      actions       = statement.value.actions
      not_actions   = try(statement.value.not_actions, null)
      effect        = try(statement.value.effect, "Allow")
      resources     = statement.value.resources
      not_resources = try(statement.value.not_resources, null)

      dynamic "condition" {
        for_each = can(statement.value.condition) && statement.value.condition != null ? statement.value.condition : []
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}