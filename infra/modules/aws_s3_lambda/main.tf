# Input S3 Bucket

resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket_name

  tags = {
    Environment = var.environment
    Purpose = "Lambda Input Bucket"
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
  name = "${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })
}

# IAM Policy for Lambda Permissions

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.environment}-lambda-policy"
  description = "Allow Lambda to read input bucket and write to output bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
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

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function

resource "aws_lambda_function" "lambda_function" {
  function_name = "${var.environment}-s3-processor"
  role = aws_iam_role.lambda_role.arn
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  filename = var.lambda_zip_path
  timeout = 30

  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
    }
  }

  tags = {
    Environment = var.environment
  }
}

# S3 Event Notification to Trigger Lambda

resource "aws_s3_bucket_notification" "input_notification" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_function.arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = var.prefix_filter
  }

  depends_on = [ aws_lambda_function.lambda_function ]
}

# Lambda Permission for S3

resource "aws_lambda_permission" "allow_s3" {
  statement_id = "AllowS3Invoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal = "s3.amazonaws.com"
  source_arn = aws_s3_bucket.input_bucket.arn
}