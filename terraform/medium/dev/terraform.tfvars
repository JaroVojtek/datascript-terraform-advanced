# PROVIDERS vars
profile    = "workload"

# GLOBAL vars
owner            = "Engineering"
environment      = "dev"
region           = "eu-central-1"
tags             = {
    "Environment": "engineering",
    "Region": "eu-central-1",
    "Profile": "workload",
}

# VPC vars
vpc_name           = "default"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.64.0/22", "10.0.68.0/22", "10.0.72.0/22"]
private_subnets    = ["10.0.80.0/22", "10.0.84.0/22", "10.0.88.0/22"]
enable_nat_gateway = true
single_nat_gateway = true