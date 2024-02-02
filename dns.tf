resource "aws_route53_zone" "primary" {
  name          = var.dns_zone
  force_destroy = true
}