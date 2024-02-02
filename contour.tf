locals {
  contour_name  = "contour"
  ingress_class = "contour"
}

resource "kubernetes_namespace_v1" "contour" {
  metadata {
    name = local.contour_name
  }
}

resource "helm_release" "contour" {
  name       = local.contour_name
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "contour"
  version    = "15.3.4"
  namespace  = kubernetes_namespace_v1.contour.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/contour.yaml", {
      class = local.ingress_class
    })
  ]

  depends_on = [
    helm_release.cluster_autoscaler,
  ]
}