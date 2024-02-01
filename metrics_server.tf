locals {
  metrics_server_name = "metrics-server"
}
resource "kubernetes_namespace_v1" "metrics_server" {
  metadata {
    name = local.metrics_server_name
  }
}

resource "helm_release" "metrics_server" {
  name       = local.metrics_server_name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"
  namespace  = kubernetes_namespace_v1.metrics_server.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/metrics_server.yaml", {
    })
  ]

  depends_on = [
    helm_release.cilium,
  ]
}