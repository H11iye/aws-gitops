# Input S3 Bucket

resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket_name

  tags = {
    Environment = var.environment
    Purpose = "Lambda Input Bucket"
    Project = var.project
  }
}

# Output S3 Bucket

resource "aws_s3_bucket" "output_bucket" {
  bucket = var.output_bucket_name

  tags = {
    Environment = var.environment
    Purpose = "Lambda Output Bucket"
  }
}

# IAM role for Lambda

resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-${var.project}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }
    ]
  })
  tags = {
    Environment = var.environment
    Project = var.project
  }
}

# Inline IAM Policy for Lambda Permissions

resource "aws_iam_policy" "lambda_inline_policy" {
  name = "${var.environment}-${var.project}-lambda-policy"
  description = "Policy for Lambda S3 to read/write and CloudWatch logs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = "S3InputRead"
            Effect = "Allow"
            Action = [
                "s3:GetObject",
                "s3:ListBucket"
            ]
            Resource = [
                aws_s3_bucket.input_bucket.arn,
                "${aws_s3_bucket.input_bucket.arn}/*"
            ]
        },
        {
            Sid = "S3OutputWrite"
            Effect = "Allow"
            Action = [
                "logs:PutObject"
            ]
            Resource = [
                "${aws_s3_bucket.output_bucket.arn}/*"
            ]
        },
        {
            Sid = "CloudWatchLogs"
            Effect = "Allow"
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:*:*:*"
        }
    ]
  })
}

# Attach Policy to Role

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "inline_attach" {
  name = "${var.environment}-${var.project}-inline"
  role = aws_iam_role.lambda_role.id
  policy = aws_iam_policy.lambda_inline_policy.policy
}

# Lambda either from ZIP (local->S3 or local copy) or from container image in ECR
# Lambda Function

resource "aws_lambda_function" "lambda_function" {
    filename = var.lambda_zip_path != "" ? var.lambda_zip_path : null
  function_name = "${var.environment}-${var.project}-processor"
  role = aws_iam_role.lambda_role.arn
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  source_code_hash = var.lambda_source_code_hash != "" ? var.lambda_source_code_hash : null
  publish = true
  timeout = var.lambda_timeout

  environment {
    variables = merge({
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
      INPUTBUCKET = aws_s3_bucket.input_bucket.bucket
      ENVIRONMENT = var.environment
      PROJECT = var.project
    }, var.extra_environment_vars)
  }

  tags = {
    Environment = var.environment
    Project = var.project
  }

  lifecycle {
    ignore_changes = var.lambda_ignore_changes ? [environment] : []
  }
}

# S3 -> Lambda notification
resource "aws_lambda_permission" "allow_s3" {
  statement_id = "AllowExecutionFromS3"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.input_bucket.arn
}

# S3 Event Notification to Trigger Lambda

resource "aws_s3_bucket_notification" "input_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = var.prefix_filter
    filter_suffix = var.suffix_filter
  }

  depends_on = [ aws_lambda_permission.allow_s3 ]
}

# Lambda Permission for S3

resource "aws_lambda_permission" "allow_s3" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.input_bucket.arn
}

# Versioning via seperate resource

resource "aws_s3_bucket_versioning" "input_bucket_versioning" {
  bucket = aws_s3_bucket.input_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Public access & ownership controls 

resource "aws_s3_bucket_public_access_block" "input_bucket_block" {
  bucket = aws_s3_bucket.input_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_ownership_controls" "input_bucket_ownership" {
  bucket = aws_s3_bucket.input_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}