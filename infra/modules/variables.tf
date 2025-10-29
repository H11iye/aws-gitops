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
  description = "Name of the cluster"
  type = string
  default = "gitops-eks"
}


variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type = string
  default = "1.28"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "aws_availability_zones_count" {
  description = "Number of availability zones to use"
  type = number
  default = 3
}

variable "node_instance_types" {
  description = "EC intance types for EKS nodes"
  type = list(string)
  default = [ "t3.medium" ]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type = number
  default = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type = number
  default = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type = number
  default = 4
}

variable "app_namespace" {
  description = "Kubernetes namespace for Next.js application"
  type = string
  default = "nextjs_app"
}

variable "ecr_repository_name" {
  description = "ECR repository name for Next.js app"
  type = string
  default = "my-nextjs-app"
}