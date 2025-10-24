variable "region" {
  description = "AWS REgion to deploy"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}

variable "project" {
  description = "dev|staging|prod"
  type = string
  default = "GITOPS_Pro"
}

variable "input_bucket_name" {
  description = "Name of the S3 input bucket"
  type = string
}

variable "output_bucket_name" {
  description = "Name of the S3 output bucket"
  type = string
}

variable "lambda_runtime" {
  description = "Lambda runtime (e.g., python3.9, nodej19.x)"
  type = string
}

variable "lambda_handler" {
  description = "Lambda function handler (e.g., inex.handler)"
  type = string
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda deployment package"
  type = string
}

variable "prefix_filter" {
  description = "Prefix filter for S3 event trigger"
  type = string
  default = ""
}

variable "enable_versioning" {
  description = "Whether versioning should be enabled on the bucket"
  type = bool
  default = true
}

variable "block_public_acls" {
  description = "Whether to block public ACLs on the bucket"
  type = bool
  default = true
}

variable "block_public_policy" {
    description = "Whether to block public bucket policies"
    type = bool
    default = true
}

variable "ignore_public_acls" {
  description = "To restrict public buckets"
  type = bool
  default = true
}

variable "object_ownership" {
  description = "Object ownership setting for the bucket"
  type = string
  default = "BucketOwnerEnforced"
}