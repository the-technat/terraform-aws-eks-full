locals {
  albc_name = "aws-load-balancer-controller"
}
resource "kubernetes_namespace_v1" "albc" {
  metadata {
    name = local.albc_name
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = local.albc_name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"
  namespace  = kubernetes_namespace_v1.albc.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/aws_load_balancer_controller.yaml", {
      region       = var.region
      cluster_name = var.cluster_name
      role_arn     = module.aws_load_balancer_controller_irsa.iam_role_arn
      vpcID        = module.vpc.vpc_id
      sa_name      = local.albc_name
    })
  ]

  depends_on = [
    helm_release.cilium,
    module.aws_load_balancer_controller_irsa,
  ]
}

module "aws_load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.1"

  role_name_prefix                       = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.albc_name}:${local.albc_name}"]
    }
  }

  tags = var.tags
}