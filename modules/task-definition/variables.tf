variable "container_definitions" {
  description = "Container definitions for the task"
  type = map(object({
    create            = optional(bool, true)
    name              = optional(string)
    image             = string
    cpu               = optional(number)
    memory            = optional(number)
    memoryReservation = optional(number)
    essential         = optional(bool, true)
    command           = optional(list(string))
    entrypoint        = optional(list(string))
    environment       = optional(list(map(string)))
    portMappings = optional(list(object({
      containerPort = number
      hostPort      = optional(number)
      protocol      = optional(string)
    })))
    healthCheck = optional(object({
      command     = list(string)
      interval    = number
      timeout     = number
      retries     = number
      startPeriod = optional(number)
    }))

    # CloudWatch Logs Configuration
    enable_cloudwatch_logging              = optional(bool, false)
    create_cloudwatch_log_group            = optional(bool, false)
    cloudwatch_log_group_name              = optional(string)
    cloudwatch_log_group_use_name_prefix   = optional(bool, false)
    cloudwatch_log_group_class             = optional(string, "STANDARD")
    cloudwatch_log_group_retention_in_days = optional(number, 30)
    cloudwatch_log_group_kms_key_id        = optional(string)

    # Other log configurations (if not using CloudWatch)
    logConfiguration = optional(any)
  }))
  default = {}
}

# IAM Role Variables
variable "create_task_execution_role" {
  description = "Whether to create a task execution IAM role"
  type        = bool
  default     = true
}

variable "task_execution_role_name" {
  description = "Name of the task execution IAM role"
  type        = string
  default     = "ecs-task-execution-role"
}

variable "task_execution_role_description" {
  description = "Description of the task execution IAM role"
  type        = string
  default     = "ECS Task Execution Role"
}

variable "external_task_execution_role_arn" {
  description = "ARN of an external task execution role (if not creating one)"
  type        = string
  default     = null
}

variable "task_execution_custom_policies" {
  description = "Custom IAM policies for task execution role (JSON)"
  type        = string
  default     = null
}

variable "task_execution_role_tags" {
  description = "Additional tags for the task execution role"
  type        = map(string)
  default     = {}
}

variable "create_task_definition" {
  description = "Whether to create a task definition"
  type        = bool
  default     = true
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = null
}

variable "memory" {
  description = "Memory for the task"
  type        = string
  default     = null
}

variable "family" {
  description = "Family name for the task definition"
  type        = string
}

variable "network_mode" {
  description = "Network mode for the task"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "ECS launch type compatibilities"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "launch_type" {
  description = "Launch type for ECS service"
  type        = string
  default     = "FARGATE"
}

variable "ephemeral_storage" {
  description = "Ephemeral storage configuration"
  type = object({
    size_in_gib = number
  })
  default = null
}

variable "enable_fault_injection" {
  description = "Enable fault injection"
  type        = bool
  default     = false
}

variable "skip_destroy" {
  description = "Skip destroy of task definition"
  type        = bool
  default     = false
}

variable "track_latest" {
  description = "Track latest task definition"
  type        = bool
  default     = false
}

variable "volumes" {
  description = "Volumes for the task definition"
  type = map(object({
    configure_at_launch = optional(bool)
    host_path           = optional(string)
    name                = optional(string)
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = optional(string)
      transit_encryption      = optional(string)
      transit_encryption_port = optional(number)
      authorization_config = optional(object({
        access_point_id = string
        iam             = optional(string)
      }))
    }))
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "task_tags" {
  description = "Additional tags for the task definition"
  type        = map(string)
  default     = {}
}
variable "current_region" {
  type = string
}