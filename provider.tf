locals {
    # region = var.region
}

terraform {
    required_version = ">= 1.2.7"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 5.0"
        }
        time = {
            source = "hashicorp/time"
            version = ">= 0.9.1"
        }
    }
}

provider "aws" {
    # profile = "default"
    # region = local.region
    region = var.region
}

