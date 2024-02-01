output "ns_records" {
  value       = aws_route53_zone.primary.name_servers
  description = "NS records for you to add"
}

output "argocd_password" {
  value       = random_password.argocd_password.result
  description = "Admin Password for Argo CD"
  sensitive   = true
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA certificate for EKS control plane endpoint"
  value       = base64decode(module.eks.cluster_certificate_authority_data)
}

output "cluster_name" {
  value       = var.cluster_name
  description = "Name of the cluster"
}