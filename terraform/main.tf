provider "aws" {
  region = "us-east-1"
}

# S3 Bucket
resource "aws_s3_bucket" "file_bucket" {
  bucket = "kundan-file-pipeline-bucket"
}

# SQS Queue
resource "aws_sqs_queue" "processed_queue" {
  name = "processed-queue"
}

# SNS Topic
resource "aws_sns_topic" "alerts_topic" {
  name = "lambda-alerts"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# IAM Policy
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["s3:*"], Resource = "*" },
      { Effect = "Allow", Action = ["sqs:*"], Resource = aws_sqs_queue.processed_queue.arn },
      { Effect = "Allow", Action = ["sns:*"], Resource = aws_sns_topic.alerts_topic.arn },
      { Effect = "Allow", Action = ["logs:*"], Resource = "*" }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "process_file" {
  function_name = "process_s3_file"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "../lambda/lambda_function.zip"

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.processed_queue.id
      SNS_TOPIC_ARN = aws_sns_topic.alerts_topic.arn
    }
  }
}

# Lambda Trigger on S3 Upload
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.file_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_file.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

# Permission for S3 to trigger Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_file.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_bucket.arn
}

# CloudWatch Alarm for Lambda failures
resource "aws_cloudwatch_metric_alarm" "lambda_failure_alarm" {
  alarm_name          = "LambdaFailureAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_actions       = [aws_sns_topic.alerts_topic.arn]
  dimensions = {
    FunctionName = aws_lambda_function.process_file.function_name
  }
}
