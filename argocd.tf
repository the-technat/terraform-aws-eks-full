locals {
  argocd_name = "argocd"
  argocd_fqdn = "cd.${var.dns_zone}"
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = local.argocd_name
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.53.9"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  wait       = true

  values = [
    templatefile("${path.module}/helm_values/argocd.yaml", {
      dns_zone          = var.dns_zone
      class             = local.ingress_class
      onboarding_folder = var.onboarding_folder
      onboarding_repo   = var.onboarding_repo
      onboarding_branch = var.onboarding_branch
    })
  ]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt_hash.argocd_password.id
  }

  depends_on = [
    helm_release.cluster_autoscaler,
  ]
}

resource "random_password" "argocd_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "bcrypt_hash" "argocd_password" {
  cleartext = random_password.argocd_password.result
}

resource "helm_release" "argocd_extras" {
  name       = "argocd-extras"
  repository = "${path.module}/charts"
  chart      = "argocd-extras"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  wait       = true

  values = [
    templatefile("${path.module}/helm_values/argocd_extras.yaml", {
      class             = local.ingress_class
      host              = local.argocd_fqdn
      onboarding_folder = var.onboarding_folder
      onboarding_repo   = var.onboarding_repo
      onboarding_branch = var.onboarding_branch
    })
  ]

  depends_on = [
    helm_release.argocd,
    helm_release.cert_manager_extras,
    helm_release.contour,
    helm_release.external_dns,
  ]
}