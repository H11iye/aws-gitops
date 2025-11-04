🚀 AWS GitOps Project with Terraform, ArgoCD, and GitHub Actions

This project implements a modern GitOps workflow on Amazon Web Services (AWS).
It provisions an EKS (Elastic Kubernetes Service) cluster using Terraform, deploys applications using ArgoCD, and builds Docker images via a GitHub Actions CI/CD pipeline that authenticates to AWS via OIDC (OpenID Connect).

🧩 Architecture Overview

             ┌──────────────────────────────┐
             │        GitHub Actions         │
             │ (CI Pipeline with OIDC Auth)  │
             └──────────────┬───────────────┘
                            │ Push Image
                            ▼
                     ┌────────────┐
                     │ AWS ECR    │
                     │ (Container │
                     │  Registry) │
                     └────┬───────┘
                          │
          ┌────────────────────────────────────┐
          │     Terraform Infrastructure       │
          │  (VPC, IAM, EKS, Node Groups)      │
          └──────────────────┬─────────────────┘
                             │
                             ▼
                  ┌────────────────────────────┐
                  │ Amazon EKS Cluster         │
                  │ (Kubernetes Control Plane) │
                  └──────────────┬─────────────┘
                                 │
                                 ▼
                       ┌────────────────┐
                       │   ArgoCD       │
                       │ (GitOps CD)    │
                       └────────────────┘

⚙️ Features

  ✅ Fully automated CI/CD pipeline using GitHub Actions.
  
  ✅ Infrastructure as Code (IaC) with Terraform.
  
  ✅ GitOps continuous deployment with ArgoCD.
  
  ✅ Secure OIDC authentication to AWS (no long-lived credentials).
  
  ✅ Scalable EKS cluster with managed node groups.
  
  ✅ Private and public subnets for production-ready networking.

🧱 Project Structure

    .
    ├── .github/workflows/
    │   └── ci-pipeline.yml       # GitHub Actions CI/CD workflow
    ├── terraform/
    │   ├── main.tf               # VPC, EKS, IAM, and ArgoCD setup
    │   ├── variables.tf          # Input variables
    │   ├── providers.tf          # AWS, Helm, Kubernetes providers
    │   ├── outputs.tf            # Terraform outputs (e.g., cluster endpoint)
    │   └── terraform.tfvars      # Custom values (optional)
    ├── app/
    │   ├── Dockerfile            # Next.js application container
    │   └── src/                  # Application code
    └── README.md

🚀 Deployment Guide

1️⃣ Configure AWS and Terraform

    aws configure
    terraform init
    terraform plan
    terraform apply -auto-approve
After apply completes, note the outputs:

  * cluster_name
    
  * cluster_endpoint

2️⃣ Connect to the EKS Cluster

    aws eks update-kubeconfig --region <your-region> --name <your-cluster-name>
    kubectl get nodes
  ✅ You should now see your worker nodes listed.

3️⃣ Access ArgoCD

  Retrieve the ArgoCD server URL and credentials:

    kubectl get svc -n argocd
    kubectl get pods -n argocd
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    
  Then open in browser:

    https://<ARGOCD_LOADBALANCER_URL>
  Username: admin
  Password: (output from above command)

4️⃣ GitHub Actions CI/CD Setup

  Your .github/workflows/ci-pipeline.yml handles:

   * Docker build & push to ECR

   * Terraform Plan & Apply

   * ArgoCD sync trigger

  Make sure you’ve configured:

  * AWS OIDC Role with policy allowing ECR and EKS actions

  * Repository secrets (if any) for dispatch tokens

🔐 Security Best Practices

  * Use OIDC authentication instead of long-lived IAM keys

  * Restrict Terraform IAM roles with least privilege

  * Store Terraform state in S3 backend with DynamoDB locking

  * Enable EKS logging for audit, API, and scheduler

  * Enforce IAM roles for service accounts (IRSA) in workloads

  * Use private subnets for worker nodes (only ALB public)

🧠 Skills and Technologies Demonstrated

    | Area                       | Skill                                                    |
    | -------------------------- | -------------------------------------------------------- |
    | **Cloud Infrastructure**   | AWS (EKS, IAM, VPC, ECR, CloudWatch)                     |
    | **Infrastructure as Code** | Terraform (modular design, remote state, variables)      |
    | **Containerization**       | Docker best practices, multi-stage builds                |
    | **Orchestration**          | Kubernetes (RBAC, namespaces, Helm charts)               |
    | **CI/CD**                  | GitHub Actions (build, deploy, Terraform workflows)      |
    | **GitOps**                 | ArgoCD configuration, declarative deployments            |
    | **Security**               | OIDC auth, least privilege IAM roles, private networking |

