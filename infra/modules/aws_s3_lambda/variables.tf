variable "region" {
  description = "AWS REgion to deploy"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
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