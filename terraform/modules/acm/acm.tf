resource "aws_acm_certificate" "cert" {
    domain_name = var.my_domain_name
    validation_method = "DNS"

    # Optionally add subject alternative names
    # subject_alternative_names = [
    #     "www.example.com"  // Replace this with your SAN if needed
    # ]

    lifecycle {
        create_before_destroy = true   
    }
}

resource "aws_route53_record" "cert_validation" {
    for_each = {
        for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
        name    = dvo.resource_record_name
        type    = dvo.resource_record_type
        record  = dvo.resource_record_value
        }
    }

    zone_id = data.aws_route53_zone.selected.zone_id
    name    = each.value.name
    type    = each.value.type
    records = [each.value.record]
    ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
    certificate_arn         = aws_acm_certificate.cert.arn
    validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}