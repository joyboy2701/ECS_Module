data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
data "aws_region" "current" {}
data "aws_kms_key" "log_group_key" {
  key_id = var.cluster.cloudwatch_log_group_kms_key_id
}