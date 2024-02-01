variable "cluster_name" {
  type        = string
  description = "Name of the cluster and it's dependend resources"
}

variable "region" {
  type        = string
  description = "AWS Region you are deploying to"
}

variable "dns_zone" {
  type        = string
  description = "A DNS zone you are able to let NS records point to Route53"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "email" {
  type        = string
  description = "Mail used for ACME and other things"
}

variable "tags" {
  type = map(string)
  default = {
    "managed-by" = "terraform"
    "repo"       = "github.com/the-technat/kubernetes-demo"
  }
  description = "Tags to apply to all resources"
}

###################
# IAM
###################
variable "aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
  description = "List of AWS IAM users you grant permissions in your cluster"
}

###################
# Networking
###################
variable "vpc_cidr" {
  type        = string
  default     = "10.123.0.0/16"
  description = "CIDR range to use for the VPC/subnets used by the cluster"
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "For true egress-traffic HA you would need at least a NAT gateway per AZ"
}

variable "service_cidr" {
  type        = string
  default     = "10.127.0.0/16"
  description = "Service CIDR used by kube-proxy and it's replacements"
}

###################
# EKS
###################
variable "eks_version" {
  type        = string
  default     = "1.28"
  description = "Cluster version to use"
}

###################
# Compute
###################
variable "desired_count" {
  type        = number
  default     = 1
  description = "Starting count of nodes per AZ"
}

variable "min_count" {
  type        = number
  default     = 1
  description = "Minimal number of nodes per AZ at any time"
}

variable "max_count" {
  type        = number
  default     = 1
  description = "Max number of nodes per AZ at any time"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3a.medium", "t3.medium", "t2.medium"]
  description = "A list of instance types to use in the cluster, the order represents the priority"
}

variable "arch" {
  type        = string
  default     = "x86_64"
  description = "Do you want a ARM or Intel|AMD based cluster?"
  validation {
    condition     = can(regex("arm64|x86_64", var.arch))
    error_message = "Supported architectures are arm64 or x86_64, mixed is not supported"
  }
}

variable "capacity_type" {
  type        = string
  default     = "SPOT"
  description = "Shall we use SPOT instances or on-demand instances?"
  validation {
    condition     = can(regex("SPOT|ON_DEMAND", var.capacity_type))
    error_message = "Supported values: SPOT|ON_DEMAND"
  }
}
