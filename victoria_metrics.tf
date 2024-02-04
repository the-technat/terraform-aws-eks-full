locals {
  vm_name = "victoria-metrics"
  vm_fqdn = "vm.${var.dns_zone}"
}
resource "kubernetes_namespace_v1" "vm" {
  metadata {
    name = local.vm_name
  }
}

resource "helm_release" "vm" {
  name       = local.vm_name
  repository = "https://victoriametrics.github.io/helm-charts/"
  chart      = "victoria-metrics-single"
  version    = "0.9.15"
  namespace  = kubernetes_namespace_v1.vm.metadata[0].name

  values = [
    templatefile("${path.module}/helm_values/vm_single.yaml", {
      class = local.ingress_class
      fqdn  = local.vm_fqdn
    })
  ]

  depends_on = [
    helm_release.aws_ebs_csi_driver,
    helm_release.ingress_nginx,
  ]
}
