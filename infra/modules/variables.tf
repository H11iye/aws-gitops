variable "region" {
  description = "AWS REgion to deploy"
  type = string
  default = "eu-west-3"
}

variable "environment" {
  description = "Environment name (dev|staging|prod)"
  type = string
  default = "dev"
}

variable "project" {
  description = "dev|staging|prod"
  type = string
  default = "GITOPS_Proj"
}

variable "cluster_name" {
  type = string
  default = "gitops-eks"
}

variable "node_instance_type" {
  type = string
  default = "t3.medium"
}

variable "node_desired_capacity" {
  type = number
  default = 2
}