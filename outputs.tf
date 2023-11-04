output "region" {
    description = "Region of the Instances"
    value = var.region
}

output "artifactsBucketName" {
    description = "Bucket Name used to configure the instances"
    value = aws_s3_bucket.artifactsBucket.id
}

output "tlsCertifcateArn" {
    description = "ACM SSL/TLS cert arn"
    value = aws_acm_certificate.main.arn
}

output "proxyInstanceRoleArn" {
    description = "The Role Arn for the Proxy Server Instance"
    value = aws_iam_role.proxyInstanceRole.arn
}

output "proxyCertAssociationPolicyArn" {
    description = "The Policy Arn for the ACM cert"
    value = aws_iam_policy.revProxyCertAssociationPolicy.arn
}

output "nucleusServerPrivateDnsName" {
    description = "Also Known as BASE_STACK_IP_OR_HOST at docker-compose env and nginx.conf"
    value = aws_instance.nucleus.private_dns
}

output "domain" {
    description = "Domain Name - FQDN"
    value = "nucleus.${var.domain_name}"
}
