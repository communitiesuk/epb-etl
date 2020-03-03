resource "aws_lambda_function" "processor" {
  filename         = var.handler.local_path
  function_name    = "${local.resource_prefix}-processor"
  role             = aws_iam_role.processor_role.arn
  handler          = "lib.bootstrap.handler"
  source_code_hash = base64encode(var.handler.actual_sha256)
  runtime          = "ruby2.7"
  tags             = var.service_tags

  environment {
    variables = {
      ETL_STAGE = var.stage
    }
  }
}

resource "aws_lambda_event_source_mapping" "processor_listener" {
  event_source_arn = aws_sqs_queue.input_queue.arn
  function_name    = aws_lambda_function.processor.arn
}

resource "aws_iam_role" "processor_role" {
  name               = "${local.resource_prefix}-processor-role"
  assume_role_policy = data.aws_iam_policy_document.processor_role.json

  tags = var.service_tags
}

data "aws_iam_policy_document" "processor_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "processor_policy" {
  name   = "${local.resource_prefix}-processor-permissions-policy"
  policy = data.aws_iam_policy_document.processor_role_permissions.json
}

resource "aws_iam_role_policy_attachment" "processor_policy" {
  role       = aws_iam_role.processor_role.name
  policy_arn = aws_iam_policy.processor_policy.arn
}

data "aws_iam_policy_document" "processor_role_permissions" {
  statement {
    actions = ["sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
    effect  = "Allow"

    resources = [aws_sqs_queue.input_queue.arn]
  }
}
