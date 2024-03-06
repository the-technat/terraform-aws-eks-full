locals {
  node_exporter_name = "node-exporter"
}

resource "kubernetes_namespace_v1" "node_exporter" {
  metadata {
    name = local.node_exporter_name
  }
  depends_on = [module.eks]
}

resource "helm_release" "node_exporter" {
  name       = local.node_exporter_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  version    = "4.31.0"
  namespace  = kubernetes_namespace_v1.node_exporter.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/node_exporter.yaml", {
    })
  ]

  depends_on = [
    helm_release.cluster_autoscaler,
  ]
}