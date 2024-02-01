locals {
  external_dns_name = "external-dns"
}
resource "kubernetes_namespace_v1" "external_dns" {
  metadata {
    name = local.external_dns_name
  }
}

resource "helm_release" "external_dns" {
  name       = local.external_dns_name
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = "1.14.3"
  namespace  = kubernetes_namespace_v1.external_dns.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/external_dns.yaml", {
      region       = var.region
      cluster_name = var.cluster_name
      role_arn     = module.aws_external_dns_irsa.iam_role_arn
      sa_name      = local.external_dns_name
    })
  ]

  depends_on = [
    helm_release.cluster_autoscaler,
    module.aws_external_dns_irsa
  ]
}

module "aws_external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.1"

  role_name_prefix           = "external-dns"
  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.external_dns_name}:${local.external_dns_name}"]
    }
  }

  tags = var.tags
}