locals {
    region = var.region
    domain = var.domain_name
    subdomain_name   = var.subdomain_name

    bucketname = aws_s3_bucket.artifactsBucket.id
    cert_arn = aws_acm_certificate.main.arn
    role_arn = aws_iam_role.proxyInstanceRole.arn
    role_policy_arn = aws_iam_policy.revProxyCertAssociationPolicy.arn
    nucleusServerPrivateDnsName = aws_instance.nucleus.private_dns
}
# bucketname - aws_s3_bucket.artifactsBucket.id
# tlsCertifcateArn - cert_arn - aws_acm_certificate.main.arn

#---------------------------------------------------------------
# Null Data Source to Load Template Data
#---------------------------------------------------------------
# May be useful later in other parts
#---------------------------------------------------------------
# Load data for aws_ec2.yaml
data "null_data_source" "aws_ec2" {
    inputs = {
        content = templatefile("./templates/aws_ec2.tftpl", {
            region = "${local.region}",
            profile_name = "${var.profile_name}"
        })
    }
}
# Load data for associate_enclave_cert
data "null_data_source" "associate_enclave_cert" {
    inputs = {
        content = templatefile("./templates/associate_enclave_cert.tftpl", {
            tlsCertificateArn = "${local.cert_arn}",
            proxyInstanceRoleArn = "${local.role_arn}",
            proxyCertAssociationPolicyArn = "${local.role_policy_arn}",
            region = "${local.region}",
            profile_name = "${var.profile_name}"
        })
    }
}
# Load data for disassociate_enclave_cert
data "null_data_source" "disassociate_enclave_cert" {
    inputs = {
        content = templatefile("./templates/disassociate_enclave_cert.tftpl", {
            tlsCertificateArn = "${local.cert_arn}",
            proxyInstanceRoleArn = "${local.role_arn}",
            region = "${local.region}",
            profile_name = "${var.profile_name}"
        })
    }
}
# Load data for nginx
data "null_data_source" "nginx" {
    inputs = {
        content = templatefile("./templates/nginx.tftpl", {
            region = "${local.region}",
            profile = "${var.profile_name}",
            Bucketname = "${local.bucketname}",
            proxyCertAssociationPolicyArn = "${local.role_policy_arn}",
            proxyInstanceRoleArn = "${local.role_arn}",
            tlsCertificateArn = "${local.cert_arn}",
            domain = "${local.subdomain_name}.${local.domain}",
            NucleusServerPrivateDnsName = "${local.nucleusServerPrivateDnsName}",
        })
    }
}
# Load data for nucleus
# base_stack_ip_or_host = NucleusServerPrivateDnsName
# If Deepsearch on same instance as Nucleus
# server_ip_or_host = NucleusServerPrivateDnsName
# server_ip_or_host = "${var.server_ip_or_host}"
data "null_data_source" "nucleus" {
    inputs = {
        content = templatefile("./templates/nucleus.tftpl", {
            region = "${local.region}",
            profile = "${var.profile_name}",
            Bucketname = "${local.bucketname}",
            domain = "${local.subdomain_name}.${local.domain}",
            instance_name = "${var.nucleusServer_instance_name}",
            NucleusServerPrivateDnsName = "${local.nucleusServerPrivateDnsName}",
            omni_farm_host = "${var.farm_host}",
            auth_root_of_trust_pub = "${var.auth_root_of_trust_pub}",
            discovery_registration_token = "${var.discovery_registration_token}",
            search_backend_type = "${var.search_backend_type}",
            search_backend_host = "${var.search_backend_host}",
            server_ip_or_host = "${local.nucleusServerPrivateDnsName}"
        })
    }
}
#---------------------------------------------------------------
# Resource local_file - create all the files
#---------------------------------------------------------------
# Create aws_ec2.yaml
resource "local_file" "aws_ec2" {
  filename = "./ansible/aws_ec2.yaml"
  content  = data.null_data_source.aaws_ec2.outputs["content"]
}
# Create associate_enclave_cert.py
resource "local_file" "associate_enclave_cert" {
  filename = "./scripts/associate_enclave_cert.py"
  content  = data.null_data_source.associate_enclave_cert.outputs["content"]
}
# Create disassociate_enclave_cert.py
resource "local_file" "disassociate_enclave_cert" {
  filename = "./scripts/disassociate_enclave_cert.py"
  content  = data.null_data_source.disassociate_enclave_cert.outputs["content"]
}
# Create nginx.yaml for group_vars
resource "local_file" "nginx_group_vars" {
  filename = "./ansible/group_vars/nginx.yaml"
  content  = data.null_data_source.nginx.outputs["content"]
}
# Create nucleus.yaml for group_vars
resource "local_file" "nucleus_group_vars" {
  filename = "./ansible/group_vars/nucleus.yaml"
  content  = data.null_data_source.nucleus.outputs["content"]
}