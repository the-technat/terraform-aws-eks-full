locals {
  cluster_autoscaler_name = "cluster-autoscaler"
}

resource "kubernetes_namespace_v1" "cluster_autoscaler" {
  metadata {
    name = local.cluster_autoscaler_name
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = local.cluster_autoscaler_name
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.34.1"
  namespace  = kubernetes_namespace_v1.cluster_autoscaler.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/cluster_autoscaler.yaml", {
      cluster_name = var.cluster_name
      region       = var.region
      sa_name      = local.cluster_autoscaler_name
      role_arn     = module.aws_cluster_autoscaler_irsa.iam_role_arn
    })
  ]

  depends_on = [
    helm_release.cilium,
    module.aws_cluster_autoscaler_irsa,
  ]
}

module "aws_cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.1"

  role_name_prefix                 = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [var.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.cluster_autoscaler_name}:${local.cluster_autoscaler_name}"]
    }
  }

  tags = var.tags
}