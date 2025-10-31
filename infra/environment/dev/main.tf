terraform {
  backend "s3" {
    bucket = "your-tfstate-bucket"
    key = "infra/dev/terraform.tfstate"
    region = "eu-west-3"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

module "s3_lambda" {
  source = "../../modules/aws_s3_lambda"
  region = var.region
  environment = "dev"
  project = var.project
  input_bucket_name = var.input_bucket_name
  output_bucket_name = var.output_bucket_name
  lambda_runtime = var.lambda_runtime
  lambda_handler = var.lambda_handler
  lambda_zip_path = var.lambda_zip_path
  lambda_source_code_hash = var.lambda_source_code_hash
  prefix_filter = var.prefix_filter
  suffix_filter = var.suffix_filter
  extra_environment_vars = {
    NEXTJS_API_URL = var.nextjs_api_url
  }
}