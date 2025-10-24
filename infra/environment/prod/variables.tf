variable "region" {
  default = "eu-west-3"
}

variable "project" {
  default = "GITOPS_Proj"
}

variable "input_bucket_name" {
  default = "gitop-prod-input-bucket"
}

variable "output_bucket_name" {
  default = "gitops-prod-output-bucket"
}

variable "lambda_zip_path" {
  default = ""
}

variable "lambda_source_code_hash" {
  default = ""
}

variable "lambda_runtime" {
  default = "nodejs18.x"
}

variable "lambda_handler" {
  default = "index.handler"
}

variable "prefix_filter" {
  default = "incoming/"
}

variable "suffix_filter" {
  default = ".json"
}

variable "nextjs_api_url" {
  default = "https://app.example.com/api"
}