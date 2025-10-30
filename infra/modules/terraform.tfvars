# EKS Cluster
cluster_name       = "nextjs-cluster"
kubernetes_version = "1.28"

# VPC
vpc_cidr = "10.0.0.0/16"

# Node Group
node_instance_types = ["t3.small"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3

# Application
app_namespace       = "nextjs-app"
ecr_repository_name = "nextjs-app"
