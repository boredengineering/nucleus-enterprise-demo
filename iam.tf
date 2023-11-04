locals {
    policy_arns = {
        "one" = aws_iam_policy.BucketObjectsPolicy.arn,
        "two" = data.aws_iam_policy.ssm_managed_policy.arn,
    }
}
#---------------------------------------------------------------
# S3 - Artifact Bucket
#---------------------------------------------------------------
resource "aws_s3_bucket" "artifactsBucket" {
    bucket_prefix = "artifactsbucket-"
    tags = {
        Name = "artifactsBucket"
    }
}
resource "aws_s3_bucket_ownership_controls" "ownership" {
    bucket = aws_s3_bucket.artifactsBucket.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}
resource "aws_s3_bucket_public_access_block" "pb" {
    bucket = aws_s3_bucket.artifactsBucket.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "acl" {
    depends_on = [ aws_s3_bucket_ownership_controls.ownership ]
    bucket     = aws_s3_bucket.artifactsBucket.id
    acl        = "private"
}
resource "aws_s3_object" "object" {
    for_each    = fileset("./artifacts/", "**")
    bucket      = aws_s3_bucket.artifactsBucket.id
    key         = each.value
    source      = "./artifacts/${each.value}"
    source_hash = filemd5("./artifacts/${each.value}")
    acl         = "aws-exec-read" 
}
#---------------------------------------------------------------
# Create Policy File
#---------------------------------------------------------------
# Policy - BucketObjectsPolicy
#---------------------------------------------------------------
resource "aws_iam_policy" "BucketObjectsPolicy"{
    name   = "BucketObjectsPolicy"
    policy = data.aws_iam_policy_document.BucketObjectsPolicy.json
}
data "aws_iam_policy_document" "BucketObjectsPolicy"{
    statement {
        effect  = "Allow"
        actions = [
            "s3:GetObject",
            "s3:ListBucket"
        ]
        resources = [
            "${aws_s3_bucket.artifactsBucket.arn}",  # artifactsBucket.bucketArn
            "${aws_s3_bucket.artifactsBucket.arn}/*" # artifactsBucket.bucketArn/*
        ]
    }
}
#---------------------------------------------------------------
# Policy - revProxyCertAssociationPolicy
#---------------------------------------------------------------
resource "aws_iam_policy" "revProxyCertAssociationPolicy"{
    name   = "revProxyCertAssociationPolicy"
    policy = data.aws_iam_policy_document.revProxyCertAssociationPolicy.json
}
data "aws_iam_policy_document" "revProxyCertAssociationPolicy"{
    statement {
        effect    = "Allow"
        actions   = ["s3:GetObject"]
        resources = ["*"]
    }
    statement {
        effect    = "Allow"
        actions   = [
            "iam:GetRole"
        ]
        resources = ["*"]
    }
    statement {
        effect    = "Allow"
        actions   = [
            "kms:Decrypt"
        ]
        resources = ["*"]
    }
}
#---------------------------------------------------------------
# Fetch an AWS Managed Policy
#---------------------------------------------------------------
data "aws_iam_policy" "ssm_managed_policy" {
    name = "AmazonSSMManagedInstanceCore" # Either we find it by name
    # arn  = "AWS managed SSM policy (AmazonSSMManagedInstanceCore)" # Or we find it by ARN
}
#---------------------------------------------------------------
# Create Role
#---------------------------------------------------------------
resource "aws_iam_role" "proxyInstanceRole" {
    name               = "proxyInstanceRole"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
resource "aws_iam_role" "nucleusInstanceRole" {
    name               = "nucleusInstanceRole"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"
        principals {
            type        = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}
#---------------------------------------------------------------
# Attach the Policy file to the Role
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "proxyInstance_policy_role" {
    for_each   = local.policy_arns
    role       = aws_iam_role.proxyInstanceRole.name
    policy_arn = each.value
}
resource "aws_iam_role_policy_attachment" "nucleusInstance_policy_role" {
    for_each   = local.policy_arns
    role       = aws_iam_role.nucleusInstanceRole.name
    policy_arn = each.value
}
# Attach revProxyCertAssociationPolicy to proxyInstance_policy_role
resource "aws_iam_role_policy_attachment" "revProxyCertAssociationPolicy" {
    role       = aws_iam_role.proxyInstanceRole.name
    policy_arn = aws_iam_policy.revProxyCertAssociationPolicy.arn
}
#---------------------------------------------------------------
# Create an Instace Profile
#---------------------------------------------------------------
resource "aws_iam_instance_profile" "proxyInstanceProfile" {
    name = "proxy_instance_profile"
    role = aws_iam_role.proxyInstanceRole.name
}

resource "aws_iam_instance_profile" "nucleusInstanceProfile" {
    name = "nucleus_instance_profile"
    role = aws_iam_role.nucleusInstanceRole.name
}