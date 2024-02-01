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
      dns_zone = var.dns_zone
      class    = local.ingress_class
    })
  ]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt_hash.argocd_password.id
  }

  depends_on = [
    module.eks,
    helm_release.cilium,
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

resource "kubernetes_ingress_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name

    annotations = {
      "cert-manager.io/cluster-issuer"           = "letsencrypt-prod"
      "ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    ingress_class_name = local.ingress_class

    rule {
      host = local.argocd_fqdn
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }

        }
      }
    }

    tls {
      hosts       = [local.argocd_fqdn]
      secret_name = "argocd-tls"
    }
  }
  depends_on = [
    helm_release.cert_manager_extras,
    helm_release.contour,
    helm_release.external_dns,
  ]
}

