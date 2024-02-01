module "eks_full" {
  source = "../"

  cluster_name = "kiwi"
  region       = "eu-west-1"       # also specify AWS_REGION env var
  dns_zone     = "aws.technat.dev" # also specify in the dns_zone data source below
  account_id   = data.aws_caller_identity.current.account_id
  email        = "technat+grapes@technat.ch"

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/technat"
      username = "technat"
      groups   = ["system:masters"]
    },
  ]

  tags = {}
}

data "aws_caller_identity" "current" {}

data "hetznerdns_zone" "dns_zone" {
  name = "technat.dev"
}

resource "hetznerdns_record" "ns_records_zone" { 
  for_each = module.eks_full.ns_records

  zone_id = data.hetznerdns_zone.dns_zone.id
  name    = "aws"
  value   = each.value
  type    = "NS"
  ttl     = 60
}