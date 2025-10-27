terraform {
  required_providers {
    aws = {source = "hashicorp/aws", version = ">= 4.60"}
  }
}

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

variable "input_bucket_name" {
  description = "Name of the S3 input bucket"
  type = string
}

variable "output_bucket_name" {
  description = "Name of the S3 output bucket"
  type = string
}

variable "enable_versioning" {
  description = "Whether versioning should be enabled on the bucket"
  type = bool
  default = false
}

variable "lifecycle_rules" {
  description = "Optional lifecycle rules (see README below)"
  type = list(object({
    id        = string
    enabled   = bool
    expiration = optional(object({ days = number }), null)
  }))
  default = []
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
  description = "Lambda timeout (seconds)"
  type = number
  default = 30
}

variable "prefix_filter" {
  description = "Prefix filter for S3 event trigger"
  type = string
  default = ""
}

variable "suffix_filter" {
  description = "S3 key suffix filter for notification"
  type = string
  default = ""
}

variable "extra_environment_vars" {
  description = "Map of additional environment variables for lambda"
  type = map(string)
  default = {}
}

variable "lambda_ignore_changes" {
  description = "If true, ignore environment changes in the lambda resource lifecycle"
  type = bool
  default = false
}
