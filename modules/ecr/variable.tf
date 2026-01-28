variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key" {
  description = "KMS key ARN (only when encryption_type = KMS)"
  type        = string
  default     = null
}
variable "force_delete" {
  description = "Force delete the repository even if it contains images"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags for the ECR repository"
  type        = map(string)
  default     = {}
}
