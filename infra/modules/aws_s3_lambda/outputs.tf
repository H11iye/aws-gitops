output "input_bucket_name" {
    description = "AWS S3 input bucket name"
  value = aws_s3_bucket.input_bucket.bucket
}

output "output_bucket_name" {
    description = "AWS S3 output bucket name"
  value = aws_s3_bucket.output_bucket.bucket
}

output "lambda_arn" {
    description = "AWS lambda function arn"
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_role_arn" {
    description = "AWS lambda role arn"
  value = aws_iam_role.lambda_role.arn
}