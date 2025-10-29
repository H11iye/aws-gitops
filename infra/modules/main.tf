##########################
# Terraform & provider configuration
##########################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

provider "aws" {
  region = var.region
}

####################
# VPC Module
####################
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name                        = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared" 
  }   
}
####################
# Internet Gateway
####################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

##############
# Public subnets
##############

resource "aws_subnet" "public" {
  count = var.aws_availability_zones_count
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                = "${var.cluster_name}-public-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernete.io/role/elb" = "1" 
  }

}

#############
# Private Subnets 
#############

resource "aws_subnet" "private" {
  count = var.aws_availability_zones_count
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.cluster_name}-private-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

##############
# Elastic IPs for NAT Gateways
##############
resource "aws_eip" "nat" {
  count = var.aws_availability_zones_count
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip-${count.index + 1}"
  }

  depends_on = [ aws_internet_gateway.main ]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.aws_availability_zones_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.cluster_name}-nat-${count.index} + 1"
  }

  depends_on = [ aws_internet_gateway.main ]
}

# Public Route Table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

# Public route table association
resource "aws_route_table_association" "public" {
  count = var.aws_availability_zones_count
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route Tables

resource "aws_route_table" "private" {
  count = var.aws_availability_zones_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt-${count.index + 1}"
  }
}

# Private route Tabel association
resource "aws_route_table_association" "private" {
  count = var.aws_availability_zones_count
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# EKS cluster IAM Role
resource "aws_iam_role" "eks-cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-vpc-resource-controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role = aws_iam_role.eks-cluster.name
}

# EKS Cluster Security Group 
resource "aws_security_group" "eks-cluster" {
  name = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id = aws_vpc.main.id

  egress = {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
} 

# EKS Cluster 
resource "aws_eks_cluster" "main" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks-cluster.arn
  version = var.kubernetes_version

  vpc_config {
    subnet_ids = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    endpoint_private_access = true
    endpoint_public_access = true
    security_group_ids = [aws_security_group.eks-cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "autenticator", "controllerManager", "scheduler"]

  depends_on = [ 
    aws_iam_role_policy_attachment.eks-cluster-policy,
    aws_iam_role_policy_attachment.eks-vpc-resource-controller,
   ]

   tags = {
     Name = var.cluster_name
   }
}