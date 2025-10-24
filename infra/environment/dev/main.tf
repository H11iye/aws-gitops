provider "aws" {
  region = var.region
}

module "s3_lambda" {
  source = "../../modules/aws_s3_lambda"
  region = var.region
  environment = "dev"
  input_bucket_name = "gitop-dev-input-bucket"
  output_bucket_name = "gitops-dev-output-bucket"
  lambda_runtime = "python3.9"
  lambda_handler = "lambda_function.lambda_handler"
  lambda_zip_path = "../../lambda_function_payload.zip"
  prefix_filter = "incoming/"
}