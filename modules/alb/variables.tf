# Target Group Variables
variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = ""
}

variable "svc_port" {
  description = "Port on which the service is running"
  type        = number
  default     = 80
}

variable "target_group_sticky" {
  description = "Whether to enable sticky sessions for the target group"
  type        = bool
  default     = false
}

variable "target_group_path" {
  description = "Path for health check on the target group"
  type        = string
  default     = "/"
}

variable "target_group_port" {
  description = "Port the target group will listen on"
  type        = number
  default     = 80
}

# Application Load Balancer (ALB) Variables
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = ""
}


variable "alb_security_groups" {
  description = "List of security groups to associate with the ALB"
  type        = list(string)
  default     = []
}

variable "internal_alb" {
  description = "Set to true if the ALB is internal"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Idle timeout value in seconds for the ALB"
  type        = number
  default     = 60
}

# S3 Bucket Variable
variable "s3_bucket" {
  description = "Name of the S3 bucket for logging or other purposes"
  type        = string
  default     = ""
}

# Validation (optional, to ensure non-empty values where needed)
variable "vpc_id" {
  description = "The ID of the VPC where the resources will be deployed"
  type        = string
  default     = ""
  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "The 'vpc_id' cannot be empty."
  }
}

variable "alb_subnets" {
  description = "List of subnets to associate with the ALB"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.alb_subnets) > 0
    error_message = "At least one subnet must be specified for 'alb_subnets'."
  }
}
