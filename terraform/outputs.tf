output "s3_bucket_name" {
  value = aws_s3_bucket.file_bucket.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.processed_queue.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts_topic.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.process_file.function_name
}
