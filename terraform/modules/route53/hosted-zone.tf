# Create an A record
resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = var.my_domain_name  # Replace with your subdomain or use "" for root domain
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}