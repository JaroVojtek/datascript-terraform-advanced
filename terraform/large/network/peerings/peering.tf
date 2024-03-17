module "vpc-peering-shared-prod" {
  source = "../../modules/vpc-peering"

  requester_vpc_cidr = data.terraform_remote_state.shared.outputs.vpc_cidr
  requester_options  = {}
  requester_tags     = {}
  accepter_vpc_cidr  = data.terraform_remote_state.prod.outputs.vpc_cidr
  accepter_options   = {}
  accepter_tags      = {}

  providers = {
    aws.requester = aws.shared
    aws.accepter  = aws.workload
  }
}

module "vpc-peering-shared-dev" {
  source = "../../modules/vpc-peering"

  requester_vpc_cidr = data.terraform_remote_state.shared.outputs.vpc_cidr
  requester_options  = {}
  requester_tags     = {}
  accepter_vpc_cidr  = data.terraform_remote_state.dev.outputs.vpc_cidr
  accepter_options   = {}
  accepter_tags      = {}

  providers = {
    aws.requester = aws.shared
    aws.accepter  = aws.workload
  }
}