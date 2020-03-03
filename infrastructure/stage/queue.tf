resource "aws_sqs_queue" "input_queue" {
  name                      = "${local.resource_prefix}-input-queue"
  max_message_size          = 2048
  message_retention_seconds = 86400
  tags                      = var.service_tags
  // @TODO add a DLQ to this queue
}

resource "aws_sqs_queue_policy" "input_sqs_policy" {
  queue_url = aws_sqs_queue.input_queue.id
  policy    = data.aws_iam_policy_document.input_sqs_policy.json
}

data "aws_iam_policy_document" "input_sqs_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.input_queue.arn]

    principals {
      identifiers = [aws_iam_role.processor_role.arn]
      type        = "AWS"
    }
  }
}
