locals {
  aws_ebs_csi_driver_name = "aws-ebs-csi-driver"
}
resource "kubernetes_namespace_v1" "aws_ebs_csi_driver" {
  metadata {
    name = local.aws_ebs_csi_driver_name
  }
}


resource "helm_release" "aws_ebs_csi_driver" {
  name       = local.aws_ebs_csi_driver_name
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.27.0"
  namespace  = kubernetes_namespace_v1.aws_ebs_csi_driver.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/aws_ebs_csi_driver.yaml", {
      region   = var.region
      sa_name  = local.aws_ebs_csi_driver_name
      role_arn = module.aws_ebs_csi_driver_irsa.iam_role_arn
    })
  ]

  depends_on = [
    helm_release.cluster_autoscaler,
  ]
}

module "aws_ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.33.1"

  role_name_prefix      = "aws-ebs-csi-driver"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.aws_ebs_csi_driver_name}:ebs-csi-controller-sa", "${local.aws_ebs_csi_driver_name}:ebs-csi-node-sa"]
    }
  }

  tags = var.tags
}