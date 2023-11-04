locals {
    domain_name   = var.domain_name
    subdomain_name   = var.subdomain_name
    # proxy_instance_name = var.proxyServer_instance_name
}
#---------------------------------------------------------------
# Create a TLS Certificate
#---------------------------------------------------------------
resource "aws_acm_certificate" "main" {
    domain_name       = local.domain_name
    subject_alternative_names = ["${local.subdomain_name}.${local.domain_name}"]
    validation_method = "DNS"
    lifecycle {
        create_before_destroy = true
    }
    tags = {
        Name = "Nucleus-certificate"
        # Environment = "test"
    }
}
# request a DNS validated certificate
resource "aws_acm_certificate_validation" "main" {
    certificate_arn         = aws_acm_certificate.main.arn
    validation_record_fqdns = [for record in aws_route53_record.dns_records : record.fqdn]
}
#---------------------------------------------------------------
# DNS Validation with Route 53
#---------------------------------------------------------------
data "aws_route53_zone" "example" {
    # name         = local.domain_name
    name = var.domain_name
    private_zone = false
}
# deploy the required validation records
resource "aws_route53_record" "dns_records" {
    for_each = {
        for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = each.value.type
    zone_id         = data.aws_route53_zone.example.zone_id
}
# Type A record pointing to Elastic Ip
resource "aws_route53_record" "server1-record" {
    allow_overwrite = true
    name    = "${local.subdomain_name}.${local.domain_name}"
    records = [aws_eip.proxy.public_ip]
    ttl     = "60"
    type    = "A"
    zone_id = data.aws_route53_zone.example.zone_id
}
