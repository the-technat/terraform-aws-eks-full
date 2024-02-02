locals {
  ksm_name = "kube-state-metrics"
}

resource "kubernetes_namespace_v1" "ksm" {
  metadata {
    name = local.ksm_name
  }
}

resource "helm_release" "ksm" {
  name       = local.ksm_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "5.16.0"
  namespace  = kubernetes_namespace_v1.ksm.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/ksm.yaml", {
    })
  ]

  depends_on = [
    helm_release.cluster_autoscaler,
    helm_release.vm,
  ]
}