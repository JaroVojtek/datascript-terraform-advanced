# PROVIDERS vars
profile    = "workload"

# GLOBAL vars
owner            = "Engineering"
environment      = "prod"
region           = "eu-central-1"
tags             = {
    "Environment": "engineering",
    "Region": "eu-central-1",
    "Profile": "workload",
}

# VPC vars
vpc_name           = "default"
vpc_cidr           = "10.224.0.0/16"
public_subnets     = ["10.224.128.0/22", "10.224.132.0/22", "10.224.136.0/22"]
private_subnets    = ["10.224.140.0/22", "10.224.144.0/22", "10.224.148.0/22"]
enable_nat_gateway = true
single_nat_gateway = true