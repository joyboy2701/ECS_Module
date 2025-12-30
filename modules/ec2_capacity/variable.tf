variable "cluster_name" {
  type = string
}
variable "subnets" {
  type = list(string)
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "desired_capacity" {
  type = number
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}
variable "ecs_ami_id" {
  type = string
}
variable "managed_termination_protection" {
  type = string
}
variable "maximum_scaling_step_size" {
  type = number
}
variable "target_capacity" {
  type = number
}
variable "minimum_scaling_step_size" {
  type = number
}
variable "managed_scaling_status" {
  type = string
}
variable "security_group_rules" {
  description = "List of security group rules"
  type = list(object({
    type            = string # "ingress" or "egress"
    description     = optional(string)
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
    self            = optional(bool, false)

  }))
  default = []
}
variable "tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = {}
}
variable "sg_name" {
  type        = string
  description = "Name prefix for ALB and related resources"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB will be deployed"
}