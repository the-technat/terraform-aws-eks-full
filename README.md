# terraform-aws-eks-full

An opiniated Terraform monolith that deploys an EKS cluster including it's network and add-ons on the cluster for a full Kubernetes experience.

## Usage

Please don't use this module! It's highly opiniated and not meant for others to use.

## Technical Debts

Currently most of the stuff the module deploys works, however:
- Many things can't be controlled from the outside (like feature toggles)
- No app is HA (to be discussed if needed or added as feature toggle)
- No app is secure (missing securityContexts)
- No app has resource requests/limits 
- No app has network policies

## Design Decisions

- Everything is deployed using Terraform 
- Dependencies shall be strict and clear, providing seamless deploy and destroy runs 
- Everything is scraped using service-based discovery

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) | 6.0.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.34.0 |
| <a name="requirement_bcrypt"></a> [bcrypt](#requirement\_bcrypt) | 0.1.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.25.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_argocd"></a> [argocd](#provider\_argocd) | 6.0.3 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.34.0 |
| <a name="provider_bcrypt"></a> [bcrypt](#provider\_bcrypt) | 0.1.2 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.12.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.25.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cluster_autoscaler_irsa"></a> [aws\_cluster\_autoscaler\_irsa](#module\_aws\_cluster\_autoscaler\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.1 |
| <a name="module_aws_ebs_csi_driver_irsa"></a> [aws\_ebs\_csi\_driver\_irsa](#module\_aws\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.1 |
| <a name="module_aws_external_dns_irsa"></a> [aws\_external\_dns\_irsa](#module\_aws\_external\_dns\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.1 |
| <a name="module_aws_load_balancer_controller_irsa"></a> [aws\_load\_balancer\_controller\_irsa](#module\_aws\_load\_balancer\_controller\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.1 |
| <a name="module_cert_manager_dns_01_irsa"></a> [cert\_manager\_dns\_01\_irsa](#module\_cert\_manager\_dns\_01\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.1 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.21.0 |
| <a name="module_grafana_irsa"></a> [grafana\_irsa](#module\_grafana\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.33.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.5.1 |

## Resources

| Name | Type |
|------|------|
| [argocd_application.app_of_apps](https://registry.terraform.io/providers/oboukili/argocd/6.0.3/docs/resources/application) | resource |
| [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/5.34.0/docs/resources/route53_zone) | resource |
| [bcrypt_hash.argocd_password](https://registry.terraform.io/providers/viktorradnai/bcrypt/0.1.2/docs/resources/hash) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager_extras](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cilium](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.grafana](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.ksm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.vm](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.argocd_server](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/ingress_v1) | resource |
| [kubernetes_ingress_v1.hubble_ui](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace_v1.albc](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.cert_manager](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.grafana](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.ingress_nginx](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.ksm](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.metrics_server](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [kubernetes_namespace_v1.vm](https://registry.terraform.io/providers/hashicorp/kubernetes/2.25.2/docs/resources/namespace_v1) | resource |
| [null_resource.purge_aws_networking](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.argocd_password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |
| [random_password.grafana_password](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/password) | resource |
| [aws_ami.eks_default](https://registry.terraform.io/providers/hashicorp/aws/5.34.0/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/5.34.0/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_arch"></a> [arch](#input\_arch) | Do you want a ARM or Intel\|AMD based cluster? | `string` | `"x86_64"` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | List of AWS IAM users you grant permissions in your cluster | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_capacity_type"></a> [capacity\_type](#input\_capacity\_type) | Shall we use SPOT instances or on-demand instances? | `string` | `"SPOT"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cluster and it's dependend resources | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Starting count of nodes per AZ | `number` | `1` | no |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | The name of a DNS zone that will be created in Route53 | `string` | n/a | yes |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | Cluster version to use | `string` | `"1.28"` | no |
| <a name="input_email"></a> [email](#input\_email) | Mail used for ACME and other things | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | A list of instance types to use in the cluster, the order represents the priority | `list(string)` | <pre>[<br>  "t3a.large",<br>  "t3.large",<br>  "t2.large"<br>]</pre> | no |
| <a name="input_max_count"></a> [max\_count](#input\_max\_count) | Max number of nodes per AZ at any time | `number` | `1` | no |
| <a name="input_min_count"></a> [min\_count](#input\_min\_count) | Minimal number of nodes per AZ at any time | `number` | `1` | no |
| <a name="input_onboarding_branch"></a> [onboarding\_branch](#input\_onboarding\_branch) | Branch to use for onboarding repo | `string` | `"HEAD"` | no |
| <a name="input_onboarding_folder"></a> [onboarding\_folder](#input\_onboarding\_folder) | Folder where Argo CD App definitions are found | `string` | `"apps"` | no |
| <a name="input_onboarding_repo"></a> [onboarding\_repo](#input\_onboarding\_repo) | Repository to configure for Argo CD App of Apps pattern | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region you are deploying to | `string` | n/a | yes |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | Service CIDR used by kube-proxy and it's replacements | `string` | `"10.127.0.0/16"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | For true HA egress-traffic disable this toggle to deploy a NAT gateway per AZ | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br>  "managed-by": "terraform",<br>  "repo": "github.com/the-technat/kubernetes-demo"<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR range to use for the VPC/subnets used by the cluster | `string` | `"10.123.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_password"></a> [argocd\_password](#output\_argocd\_password) | Admin Password for Argo CD |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | CA certificate for EKS control plane endpoint |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the cluster |
| <a name="output_grafana_password"></a> [grafana\_password](#output\_grafana\_password) | Admin Password for Grafana |
| <a name="output_ns_records"></a> [ns\_records](#output\_ns\_records) | NS records of the created DNS |
<!-- END_TF_DOCS -->