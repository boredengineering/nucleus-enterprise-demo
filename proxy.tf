#---------------------------------------------------------------
# AWS ACM Nitro Enclaves - NGINX Proxy Server Instance
#---------------------------------------------------------------
resource "aws_instance" "reverseProxyServer" {
    # When you Cannot locate the AMI programmatically use the AMI id
    # ami = var.proxyServerAMI_List[var.region]
    ami             = data.aws_ami.nitro_ami.id
    instance_type   = local.proxy_instance_type

    vpc_security_group_ids = [aws_security_group.proxySG.id]
    # deploy using the first public subnet id from VPC module
    subnet_id = module.vpc.public_subnets[0]
    iam_instance_profile = aws_iam_instance_profile.proxyInstanceProfile.name

    enclave_options {
        enabled = true
    }

    ebs_block_device {
        device_name = "/dev/xvda"
        volume_size = 32
    }
    tags = {
        Name = local.proxy_instance_name
    }
    depends_on = [
        aws_security_group.proxySG
    ]
}
#---------------------------------------------------------------
# AWS Certificate Manager for Nitro Enclaves AMI
#---------------------------------------------------------------
# PROBLEM
data "aws_ami" "nitro_ami" {
    most_recent = true
    owners = ["679593333241"]
    include_deprecated = true
    filter {
        name   = "name"
        # values = ["ACM-For-Nitro-Enclaves-1-2-0_2022-09-09T11-07-26.526Z-3f5ee4f8-1439-4bce-ac57-e794a4ca82f9*"]
        values = ["ACM-For-Nitro-Enclaves*"]
    }
}
#---------------------------------------------------------------
# Security Group for Proxy Server
#---------------------------------------------------------------
resource "aws_security_group" "proxySG" {
    name        = "proxySG"
    description = "Security Group for AWS Nitro Enclaves NGINX Reverse Proxy Server"
    # vpc_id      = aws_vpc.vpc.id
    vpc_id      = module.vpc.vpc_id

    egress {
        description = "Allows all Traffic Egress"    
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "proxySG"
    }
}
resource "aws_security_group_rule" "proxySG_ingress_rules" {
    count = length(var.proxySG_ingress_rules)

    type              = "ingress"
    description       = var.proxySG_ingress_rules[count.index].description
    from_port         = var.proxySG_ingress_rules[count.index].from_port
    to_port           = var.proxySG_ingress_rules[count.index].to_port
    protocol          = var.proxySG_ingress_rules[count.index].protocol
    cidr_blocks       = [var.proxySG_ingress_rules[count.index].cidr_block]
    
    security_group_id = aws_security_group.proxySG.id
}
#---------------------------------------------------------------
# Associate Elastic IP with an instance
#---------------------------------------------------------------
resource "aws_eip" "proxy" {
    instance = aws_instance.reverseProxyServer.id
    domain   = "vpc"
    tags = {
        Name = local.proxy_instance_name
    }
}
#---------------------------------------------------------------
# Associate Enclave Cert
#---------------------------------------------------------------
resource "time_sleep" "wait_30_seconds" {
  depends_on = [local_file.associate_enclave_cert]

  create_duration = "30s"
}

# python3 -m associate_enclave_cert.py
resource "null_resource" "associate_enclave_cert" {
    provisioner "local-exec" {
        command = <<EOT
            python3 -m associate_enclave_cert '{"key_1": "value_1"}'
        EOT
        working_dir = "${path.module}/scripts"
    }
    depends_on = [time_sleep.wait_30_seconds]
}

#---------------------------------------------------------------
# Disassociate Enclave Cert
#---------------------------------------------------------------
resource "time_sleep" "wait_destroy" {
    depends_on = [local_file.disassociate_enclave_cert]

    destroy_duration = "30s"
}
# python3 -m disassociate_enclave_cert.py
resource "null_resource" "disassociate_enclave_cert" {
    provisioner "local-exec" {
        when = destroy
        command = <<-EOT
            python3 -m disassociate_enclave_cert '{"key_1": "value_1"}'
        EOT
        working_dir = "${path.module}/scripts"
    }
    depends_on = [time_sleep.wait_destroy]
}
