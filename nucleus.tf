locals {
    nucleus_instance_name = var.nucleusServer_instance_name
    nucleus_instance_type = var.nucleusServer_instance_type
}
#---------------------------------------------------------------
# Nucleus Server Instance
#---------------------------------------------------------------
resource "aws_instance" "nucleus" {
    ami             = data.aws_ami.nucleus_ami.id
    instance_type   = local.nucleus_instance_type

    vpc_security_group_ids = [aws_security_group.nucleusSG.id]
    # deploy using the first private subnet id from VPC module
    subnet_id = module.vpc.private_subnets[0]
    iam_instance_profile = aws_iam_instance_profile.nucleusInstanceProfile.name

    ebs_block_device {
        device_name = "/dev/sda1"
        volume_size = 512
    }
    tags = {
        Name = local.nucleus_instance_name
    }
    depends_on = [
        aws_security_group.nucleusSG
    ]
}
#---------------------------------------------------------------
# Nucleus AMI - Canonical Ubuntu 22.04 LTS Community Version
#---------------------------------------------------------------
data "aws_ami" "nucleus_ami" {
    most_recent = true
    owners = ["099720109477"] # Owner id: 099720109477 # canonical Ubuntu
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
    }
}
#---------------------------------------------------------------
# Security Group for Nucleus Server
#---------------------------------------------------------------
resource "aws_security_group" "nucleusSG" {
    name        = "nucleusSG"
    description = "Security Group for Nucleus Server"
    vpc_id      = module.vpc.vpc_id
    egress {
        description = "Allows all Traffic Egress"    
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "nucleusSG"
    }
}
resource "aws_security_group_rule" "nucleusSG_ingress_rules" {
    count = length(var.nucleusSG_ingress_rules)

    type              = "ingress"
    description       = var.nucleusSG_ingress_rules[count.index].description
    from_port         = var.nucleusSG_ingress_rules[count.index].from_port
    to_port           = var.nucleusSG_ingress_rules[count.index].to_port
    protocol          = var.nucleusSG_ingress_rules[count.index].protocol
    cidr_blocks       = [var.nucleusSG_ingress_rules[count.index].cidr_block]
    
    security_group_id = aws_security_group.nucleusSG.id
}
#---------------------------------------------------------------
# End of Nucleus Server
#---------------------------------------------------------------