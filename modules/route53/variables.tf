variable "domain_name" {
  description = "The primary domain name for the certificate"
  type        = string
  default     = "mywebsite.org"
}

variable "san_names" {
  description = "Subject Alternative Names (SANs) for the certificate"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "alb_dns_name" {
  description = "The DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "The Zone ID of the ALB"
  type        = string
}