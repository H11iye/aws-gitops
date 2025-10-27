provider "aws" {
  region = var.region
}

# Input S3 Bucket

resource "aws_s3_bucket" "input_bucket" {
  bucket = var.input_bucket_name

  tags = {
    Environment = var.environment
    Purpose = "Lambda Input Bucket"
    Project = var.project
    ManagedBy = "terraform"
  }
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

resource "aws_s3_bucket_lifecycle_configuration" "input_lifecycle" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.input_bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "expiration" {
        for_each = rule.value.expiration == null ? [] : [1]
        content {
          days = rule.value.expiration.days
        }
      }
    }
  }
}

# Output S3 Bucket

resource "aws_s3_bucket" "output_bucket" {
  bucket = var.output_bucket_name

  tags = {
    Environment = var.environment
    Purpose = "Lambda Output Bucket"
    Project = var.project
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "output_bucket_versioning" {
  bucket = aws_s3_bucket.output_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "output_bucket_block" {
  bucket = aws_s3_bucket.output_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "output_bucket_ownership" {
  bucket = aws_s3_bucket.output_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "output_lifecycle" {
  count  = length(var.lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.output_bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "expiration" {
        for_each = rule.value.expiration == null ? [] : [1]
        content {
          days = rule.value.expiration.days
        }
      }
    }
  }
}
#----------------------
# IAM role for Lambda
#----------------------
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

# Managed execution permissions (CloudWatch basic)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline IAM Policy for Lambda Permissions (least privilege) S3 input read, S3 output put, CloudWatch logs

resource "aws_iam_policy_document" "lambda_policy" {
  name = "${var.environment}-${var.project}-lambda-policy"
  description = "Policy for Lambda S3 to read/write and CloudWatch logs"
  statement {
    sid = "ListInputBucket"
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.input_bucket.arn]
  }

  statement {
    sid = "GetInputObjects"
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources =["${aws_s3_bucket.input_bucket.arn}/*"]
  }

  statement {
    sid = "PutOutputObjects"
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.output_bucket.arn}/*"]
  }

  statement {
    sid = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name = "${var.environment}-${var.project}-lambda-inline"
  role = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# Lambda either from ZIP (local->S3 or local copy) or from container image in ECR
# Lambda Function

resource "aws_lambda_function" "lambda_function" {
  count            = var.lambda_zip_path == "" ? 0 : 1
  function_name    = "${var.environment}-${var.project}-processor"

  filename         = var.lambda_zip_path
  # compute hash if file exists; if not present, leave null (Terraform may error if file missing)
  source_code_hash = var.lambda_source_code_hash != "" ? var.lambda_source_code_hash : null
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_role.arn
  timeout          = var.lambda_timeout
  publish          = true

  environment {
    variables = merge({
      INPUT_BUCKET  = aws_s3_bucket.input_bucket.bucket
      OUTPUT_BUCKET = aws_s3_bucket.output_bucket.bucket
      ENVIRONMENT   = var.environment
      PROJECT       = var.project
    }, var.extra_environment_vars)
  }

  tags = {
    Environment = var.environment
    Project     = var.project
  }

  lifecycle {
    ignore_changes = var.lambda_ignore_changes ? [environment] : []
  }
}
#------------------------------
# Allow S3 to invoke Lambda
#------------------------------

# S3 -> Lambda notification
  resource "aws_lambda_permission" "allow_s3" {
  count = var.lambda_zip_path == "" ? 0 : 1

  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[0].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# S3 Event Notification to Trigger Lambda
resource "aws_s3_bucket_notification" "input_notification" {
  count  = var.lambda_zip_path == "" ? 0 : 1
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda[0].arn
    events              = ["s3:ObjectCreated:*"]

    dynamic "filter" {
      for_each = var.prefix_filter == "" && var.suffix_filter == "" ? [] : [1]
      content {
        key {
          dynamic "filter_rule" {
            for_each = var.prefix_filter != "" ? [1] : []
            content {
              name  = "Prefix"
              value = var.prefix_filter
            }
          }
          dynamic "filter_rule" {
            for_each = var.suffix_filter != "" ? [1] : []
            content {
              name  = "Suffix"
              value = var.suffix_filter
            }
          }
        }
      }
    }
  }

  depends_on = [aws_lambda_permission.allow_s3]
}







