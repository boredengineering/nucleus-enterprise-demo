variable "domain_name" {
    description = "FQDN (Fully Qualified Domain Name)"
    type        = string
}
variable "subdomain_name" {
    description = "subdomain for the FQDN (Fully Qualified Domain Name)"
    type        = string
}
variable "region" {
    description = "Region to create the instance"
    type        = string
}
variable "profile_name" {
    description = "AWS SSO Profile Name, same used for BotoCore"
    type        = string
}
#---------------------------------------------------------------
# Farm Stuff
#---------------------------------------------------------------
variable "farm_host" {
    description = "omni_farm_host - Where Farm Queue Ip is. If running locally default to localhost"
    type        = string
    default     = "localhost"
}
#---------------------------------------------------------------
# DeepSearch Stuff
#---------------------------------------------------------------
# variable "server_ip_or_host" {
#     description = "Server where DeepSearch stack is running"
#     type        = string
#     # default     = ""
# }
variable "auth_root_of_trust_pub" {
    description = "authentication public key"
    type        = string
    default     = "./secrets/auth_root_of_trust.pub"
}
variable "discovery_registration_token" {
    description = "service registration token"
    type        = string
    default     = "./secrets/svc_reg_token"
}
variable "search_backend_type" {
    description = "NG-Search backend - either ElasticSearch es_index or OpenSearch os_index"
    type        = string
    default     = "os_index"
}
variable "search_backend_host" {
    description = "NG-Search backend host - defaults to the Test open-search host"
    type        = string
    default     = "open-search"
}

#---------------------------------------------------------------
# ACM-For-Nitro-Enclaves AMIs 
# ACM-For-Nitro-Enclaves-1-0-2_ 2021-04-29T21-09-41.751Z-3f5ee4f8-1439-4bce-ac57-e794a4ca82f9-ami-028ce88e069714286.4
# 2021-04-30T00:01:19.000Z
# Older AMIs good backup plan
#---------------------------------------------------------------
variable "proxyServerAMI_List" {
    description = "AWS Nitro Enclaves List of AMIs"
    type        = map(string)
    default     = {
        us-east-1 =    "ami-00d96e5ee00daa484" , # virginia
        us-east-2 =    "ami-020ea706ac260de21" , # ohio
        us-west-1 =    "ami-0213075968e811ea7" , # california
        us-west-2 =    "ami-05421ae6be0ecba36" , # oregon - older "ami-01c4415fd6c2f0927"
        ca-central-1 = "ami-096dd1150b96b6125" , # canada
        eu-central-1 = "ami-06a2b19f6b97762cb" , # frankfurt
        eu-west-1 =    "ami-069e205c9dea19322" , # ireland
        eu-west-2 =    "ami-069b79a2d7d0d9408" , # london
    } 
}
#---------------------------------------------------------------
# Network
#---------------------------------------------------------------
# 10.0.0.0/20
variable "cidr_block" {
    default = "10.0.0.0/16"
}
variable "subnet" {
    default = "10.0.0.0/24"
}
#---------------------------------------------------------------
# Nucleus Server
#---------------------------------------------------------------
variable "nucleusServer_instance_name" {
    description = "Name of instance"
    type        = string
}
variable "nucleusServer_instance_type" {
    description = "The instance type"
    type        = string
    default     = "c5.4xlarge"
}
#---------------------------------------------------------------
# Proxy Server
#---------------------------------------------------------------
variable "proxyServer_instance_name" {
    description = "Name of proxyServer instance"
    type        = string
}
variable "proxyServer_instance_type" {
    description = "The proxyServer instance type"
    type        = string
    default     = "c5.xlarge"
}
#---------------------------------------------------------------
# Nucleus Server Security Group
#---------------------------------------------------------------
variable "nucleusSG_ingress_rules" {
    type = list(object({
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_block  = string
    }))
    default     = [
        {
            description = "HTTP Traffic"
            from_port   = 8080
            to_port     = 8080
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Auth login"
            from_port   = 3180
            to_port     = 3180
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Auth Service"
            from_port   = 3100
            to_port     = 3100
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Discovery Service"
            from_port   = 3333
            to_port     = 3333
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "LFT"
            from_port   = 3030
            to_port     = 3030
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Core API"
            from_port   = 3019
            to_port     = 3019
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Tagging Service"
            from_port   = 3020
            to_port     = 3020
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Search Service"
            from_port   = 3400
            to_port     = 3400
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
    ]
}
#---------------------------------------------------------------
# Proxy Server Security Group
#---------------------------------------------------------------
variable "proxySG_ingress_rules" {
    type = list(object({
        description = string
        from_port   = number
        to_port     = number
        protocol    = string
        cidr_block  = string
    }))
    default     = [
        {
            description = "HTTPS Traffic"
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Auth login"
            from_port   = 3180
            to_port     = 3180
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Auth Service"
            from_port   = 3100
            to_port     = 3100
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Discovery Service"
            from_port   = 3333
            to_port     = 3333
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "LFT"
            from_port   = 3030
            to_port     = 3030
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Core API"
            from_port   = 3019
            to_port     = 3019
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Tagging Service"
            from_port   = 3020
            to_port     = 3020
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
        {
            description = "Search Service"
            from_port   = 3400
            to_port     = 3400
            protocol    = "tcp"
            cidr_block  = "0.0.0.0/0"
        },
    ]
}