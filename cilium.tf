resource "null_resource" "purge_aws_networking" {
  triggers = {
    eks = module.eks.cluster_endpoint # only do this when the cluster changes (e.g create/recreate)
  }
  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name} --alias ${var.cluster_name}
      curl -L -o /tmp/kubectl https://dl.k8s.io/release/v${var.eks_version}.0/bin/linux/amd64/kubectl
      chmod 0755 /tmp/kubectl
      /tmp/kubectl -n kube-system delete daemonset kube-proxy --ignore-not-found 
      /tmp/kubectl -n kube-system delete daemonset aws-node --ignore-not-found
      rm /tmp/kubectl
    EOT
  }
  # Note: we don't deploy the addons using TF, but the resources are still there on cluster creation
  # That's why it's enough to delete them once as soon as the control-plane is ready
  depends_on = [
    module.eks.aws_eks_cluster,
  ]
}

resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.14.6"
  namespace  = "kube-system"
  wait       = true
  timeout    = 3600
  values = [
    templatefile("${path.module}/helm_values/cilium.yaml", {
      cluster_endpoint = trim(module.eks.cluster_endpoint, "https://") # used for kube-proxy replacement
      cluster_name     = var.cluster_name
    })
  ]
  depends_on = [
    null_resource.purge_aws_networking,
  ]
}