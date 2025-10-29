module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
        desired_size = var.node_desired_capacity
        max_size = var.node_desired_capacity + 1
        min_size = 1
        instance_types= [var.node_instance_type]
        
    }
  }

  manage_aws_auth = true
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}
