data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}
data "aws_region" "current" {}
data "aws_kms_key" "wordpress" {
  key_id = "d33f023a-8e2f-47a5-8fa7-22adf1f65d13"
}