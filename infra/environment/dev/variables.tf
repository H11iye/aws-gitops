variable "region" {
  default = "eu-west-3"
}

variable "project" {
  default = "GITOPS_Proj"
}

variable "input_bucket_name" {
  default = "gitop-dev-input-bucket"
}

variable "output_bucket_name" {
  default = "gitops-dev-output-bucket"
}

variable "lambda_runtime" {
  default = "nodejs18.x"
}

variable "lambda_handler" {
  default = "index.handler"
}

# For dev we will let CI upload a zip to infra/artifacts/ or to S3 and set the path here
variable "lambda_zip_path" {
  description = "Local path to zip (for terraform apply). Ci may upload the zip to S3 and set an s3:// URL or use local artifact in repo."
  default = "lambda_payloads/dev_lambda.zip"
}

variable "lambda_source_code_hash" {
  default = ""
}

variable "prefix_filter" {
  default = "incoming/"
}

variable "suffix_filter" {
  default = ".json"
}

variable "nextjs_api_url" {
  description = "URL to next.js API(if the lambda needs to call the next.js app)"
  default = "https://dev.example.com/api"
}