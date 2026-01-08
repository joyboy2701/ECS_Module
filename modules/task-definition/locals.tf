locals {
  task_role_policies = {
    count         = try(var.create_tasks_iam_role, false) ? 1 : 0
    assume_policy = try(data.aws_iam_policy_document.task_role_assume[0].json, null)
    policy_json   = try(data.aws_iam_policy_document.task_role[0].json, null)
  }
}

