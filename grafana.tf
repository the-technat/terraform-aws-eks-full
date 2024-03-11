locals {
  grafana_name = "grafana"
  grafana_fqdn = "graphs.${var.dns_zone}"
}
resource "kubernetes_namespace_v1" "grafana" {
  metadata {
    name = local.grafana_name
  }
  depends_on = [module.eks]
}

resource "helm_release" "grafana" {
  name       = local.grafana_name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.4"
  namespace  = kubernetes_namespace_v1.grafana.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/grafana.yaml", {
      host    = local.grafana_fqdn
      class   = local.ingress_class
      rolearn = module.grafana_irsa.iam_role_arn
      region  = var.region

    })
  ]

  set_sensitive {
    name  = "adminPassword"
    value = random_password.grafana_password.result
  }

  depends_on = [
    helm_release.vm,
    helm_release.ingress_nginx,
    helm_release.aws_ebs_csi_driver,
  ]
}

resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "grafana_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.37.1"

  role_name_prefix = "grafana"
  role_policy_arns = {
    "CloudWatchReadOnlyAccess" = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
  }


  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.grafana_name}:${local.grafana_name}"]
    }
  }

  tags = var.tags
}