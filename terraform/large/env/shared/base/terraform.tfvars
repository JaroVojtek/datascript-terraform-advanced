# PROVIDERS vars
profile    = "shared"

# GLOBAL vars
owner            = "Engineering"
environment      = "shared-large"
region           = "eu-central-1"
tags             = {
    "Environment": "engineering",
    "Region": "eu-central-1",
    "Profile": "shared",
}

# VPC vars
vpc_name           = "default"
vpc_cidr           = "10.3.0.0/16"
public_subnets     = ["10.3.0.0/22", "10.3.4.0/22", "10.3.8.0/22"]
private_subnets    = ["10.3.12.0/22", "10.3.16.0/22", "10.3.20.0/22"]
enable_nat_gateway = true
single_nat_gateway = true