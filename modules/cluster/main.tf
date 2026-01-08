data "aws_kms_key" "log_group_key" {
  key_id = var.cloudwatch_log_group_kms_key_id
}
resource "aws_ecs_cluster" "this" {
  count = var.create ? 1 : 0
  
  dynamic "configuration" {
    for_each = var.configuration != null ? [var.configuration] : []

    content {

      dynamic "managed_storage_configuration" {
        for_each = configuration.value.managed_storage_configuration != null ? [configuration.value.managed_storage_configuration] : []

        content {
          kms_key_id = managed_storage_configuration.value.cloudwatch_log_group_kms_key_id
        }
      }
    }
  }
  name = var.name

  dynamic "setting" {
    for_each = var.setting != null ? var.setting : []

    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create && var.create_cloudwatch_log_group ? 1 : 0

  name              = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = data.aws_kms_key.log_group_key.arn
  log_group_class   = var.cloudwatch_log_group_class

  tags = merge(
    var.tags,
    var.cloudwatch_log_group_tags,
    { Name = var.cloudwatch_log_group_name }
  )
}