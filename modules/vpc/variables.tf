variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "environment" {
  description = "Environment name"
  type        = string
}
variable "subnet_types" {
  description = "Map of subnet types"
  type        = map(string)
}
variable "cidr_block" {
  description = "Cidr Block 0.0.0.0/0"
  type        = string
}
variable "domain" {
  description = "Domain for NAT Gateway"
  type        = string
}
variable "dns_host_name" {
  description = "DNS host name enable/disable"
  type        = bool
}
variable "enable_dns_support" {
  description = "DNS support enable/disable"
  type        = bool
}
variable "map_public_ip_on_launch" {
  type = bool
}