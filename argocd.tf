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
  version    = "5.54.0"
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


resource "kubernetes_ingress_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name

    annotations = {
      "cert-manager.io/cluster-issuer"               = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-passthrough"  = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
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
                name = "https"
              }
            }
          }

        }
      }
    }

    tls {
      hosts       = [local.argocd_fqdn]
      secret_name = "argocd-server-tls"
    }
  }
  depends_on = [
    helm_release.cert_manager_extras,
    helm_release.ingress_nginx,
    helm_release.external_dns,
  ]
}

resource "argocd_application" "app_of_apps" {
  metadata {
    name      = "app-of-apps"
    namespace = "argocd"
  }

  cascade = false # disable cascading deletion
  wait    = true

  spec {
    project = "default"

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "argocd"
    }

    source {
      repo_url        = var.onboarding_repo
      path            = var.onboarding_folder
      target_revision = var.onboarding_branch
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      sync_options = ["ServerSideApply=true"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }
  }

  depends_on = [helm_release.argocd, ]
}