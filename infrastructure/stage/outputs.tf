output "processor_role" {
  value = aws_iam_role.processor_role.arn
}

output "stage_input_queue_arn" {
  value = aws_sqs_queue.input_queue.arn
}
