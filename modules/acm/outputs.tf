output "acm_id" {
  value = aws_acm_certificate.certificate.id
}
output "acm_domain_name" {
  value = aws_acm_certificate.certificate.domain_name
}
