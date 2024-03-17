data "aws_caller_identity" "accepter" {
  count = var.enabled ? 1 : 0

  provider = aws.accepter
}

data "aws_region" "accepter" {
  count = var.enabled ? 1 : 0

  provider = aws.accepter
}

data "aws_vpc" "accepter" {
  count = var.enabled ? 1 : 0

  cidr_block = var.accepter_vpc_cidr

  provider = aws.accepter
}

data "aws_vpc" "requester" {
  count = var.enabled ? 1 : 0

  cidr_block = var.requester_vpc_cidr

  provider = aws.requester
}

resource "aws_vpc_peering_connection" "connection" {
  count = var.enabled ? 1 : 0

  vpc_id        = data.aws_vpc.requester[0].id
  peer_owner_id = data.aws_caller_identity.accepter[0].account_id
  peer_region   = data.aws_region.accepter[0].name
  peer_vpc_id   = data.aws_vpc.accepter[0].id

  auto_accept = false

  provider = aws.requester
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  count = var.enabled ? 1 : 0

  auto_accept               = true
  tags                      = var.accepter_tags
  vpc_peering_connection_id = aws_vpc_peering_connection.connection[0].id

  provider = aws.accepter
}

resource "aws_vpc_peering_connection_options" "accepter" {
  count = var.enabled && length(keys(var.accepter_options)) > 0 ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.connection[0].id

  accepter {
    allow_remote_vpc_dns_resolution = lookup(var.accepter_options, "allow_remote_vpc_dns_resolution", false)
  }

  provider = aws.accepter
}

resource "aws_vpc_peering_connection_options" "requester" {
  count = var.enabled && length(keys(var.requester_options)) > 0 ? 1 : 0

  vpc_peering_connection_id = aws_vpc_peering_connection.connection[0].id

  accepter {
    allow_remote_vpc_dns_resolution = lookup(var.requester_options, "allow_remote_vpc_dns_resolution", false)
  }

  provider = aws.requester
}
