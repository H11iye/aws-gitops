variable "region" {
  description = "AWS REgion to deploy"
  type = string
  default = "eu-west-3"
}

variable "environment" {
  description = "Environment name (dev|staging|prod)"
  type = string
}

variable "project" {
  description = "dev|staging|prod"
  type = string
  default = "GITOPS_Proj"
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
  default = "nodejs18.x"
}

variable "lambda_handler" {
  description = "Lambda function handler (e.g., inex.handler)"
  type = string
  default = "index.handler"
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda deployment package"
  type = string
  default = ""
}

variable "lambda_source_code_hash" {
  description = "Base64 SHA256 of zip for change detection"
  type = string
  default = ""
}

variable "lambda_timeout" {
  type = number
  default = 30
}

variable "prefix_filter" {
  description = "Prefix filter for S3 event trigger"
  type = string
  default = ""
}

variable "suffix_filter" {
  type = string
  default = ""
}

variable "extra_environment_vars" {
  type = map(string)
  default = {}
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