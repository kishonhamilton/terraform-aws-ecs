# Data Sources: Route 53 Zone lookups
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

data "aws_route53_zone" "subdomain_zone" {
  name         = "app.${var.domain_name}"
  private_zone = false
}

# Conditionally create subdomain if it doesn't exist
resource "aws_route53_zone" "subdomain" {
  count         = length(data.aws_route53_zone.subdomain_zone) == 0 ? 1 : 0
  name          = "app.${var.domain_name}"
  force_destroy = false
  tags          = var.tags
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names  = var.san_names
  validation_method          = "DNS"
  tags                       = var.tags
}

# DNS Validation records for the certificate
resource "aws_route53_record" "cert_records" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
      zone_id = dvo.domain_name == var.domain_name ? data.aws_route53_zone.main.zone_id : aws_route53_zone.subdomain[0].id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = each.value.zone_id
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_records : record.fqdn]
}

# Alias Record for the Primary Domain
resource "aws_route53_record" "alias_route53_record" {
  name    = var.domain_name
  zone_id = data.aws_route53_zone.main.zone_id
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Alias Records for the SANs (Subject Alternative Names)
resource "aws_route53_record" "SAN_alias_route53_record" {
  for_each = toset(var.san_names)
  name     = each.value
  zone_id  = data.aws_route53_zone.main.zone_id
  type     = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Outputs
output "subdomain_zone_id" {
  value = length(data.aws_route53_zone.subdomain_zone) > 0 ? data.aws_route53_zone.subdomain_zone.id : aws_route53_zone.subdomain[0].id
}

output "main_zone_id" {
  value = data.aws_route53_zone.main.id
}
