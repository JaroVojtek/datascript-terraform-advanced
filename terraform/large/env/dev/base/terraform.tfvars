# PROVIDERS vars
profile    = "workload"

# GLOBAL vars
owner            = "Engineering"
environment      = "dev-large"
region           = "eu-central-1"
tags             = {
    "Environment": "engineering",
    "Region": "eu-central-1",
    "Profile": "workload",
}

# VPC vars
vpc_name           = "default"
vpc_cidr           = "10.1.0.0/16"
public_subnets     = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
private_subnets    = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]
enable_nat_gateway = true
single_nat_gateway = true