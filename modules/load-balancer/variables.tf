variable "name" {
  type        = string
  description = "Name prefix for ALB and related resources"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID where ALB will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets to attach the ALB to"
}

variable "target_port" {
  type        = number
  description = "Port where ALB will forward traffic (ECS container port)"
}
variable "listner_port" {
  type = number
}

variable "protocol" {
  type        = string
  description = "ALB listener protocol"
}
variable "load_balancer_type" {
  type        = string
  description = "load balancer type"
}
variable "target_type" {
  type        = string
  description = "target  type"
}

variable "internal" {
  type        = bool
  description = "Whether the ALB is internal"
  default     = true
}
variable "enable_deletion_protection" {
  type    = bool
  default = false
}
variable "idle_timeout" {
  type        = number
  description = "Timeout for Load Balancer"
}
variable "healthcheck_healthy_threshold" {
  type = number
}
variable "healthcheck_unhealthy_threshold" {
  type = number
}
variable "healthcheck_healthy_timeout" {
  type = number
}
variable "healthcheck_interval" {
  type = number
}
variable "action_type" {
  type = string
}
variable "healthCheck_path" {
  type = string
}
variable "matcher" {
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