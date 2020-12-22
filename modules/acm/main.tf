resource "aws_acm_certificate" "certificate" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "EMAIL"
  subject_alternative_names = [var.domain_name]
}
