resource "aws_lambda_function" "processor" {
  function_name    = "${local.resource_prefix}-processor"
  role             = aws_iam_role.processor_role.arn
  handler          = "lib/bootstrap.handler"
  source_code_hash = var.handler.actual_sha256
  runtime          = "ruby2.7"
  tags             = var.service_tags
  timeout          = 900
  layers           = [for layer in aws_lambda_layer_version.layer : layer.arn]
  s3_bucket        = var.handler.s3_bucket
  s3_key           = var.handler.s3_key

  vpc_config {
    security_group_ids = var.vpc_config.security_group_ids
    subnet_ids         = var.vpc_config.subnet_ids
  }

  environment {
    variables = merge({
      ETL_STAGE = var.stage
      NEXT_SQS_URL = var.output_queue_url
    }, var.environment)
  }
}

resource "aws_lambda_layer_version" "layer" {
  for_each         = var.layers
  layer_name       = "${local.resource_prefix}-processor-${each.key}"
  s3_bucket        = each.value.s3_bucket
  s3_key           = each.value.s3_key
  source_code_hash = each.value.actual_sha256
}

resource "aws_lambda_event_source_mapping" "processor_listener" {
  event_source_arn = aws_sqs_queue.input_queue.arn
  function_name    = aws_lambda_function.processor.arn
}

resource "aws_iam_role" "processor_role" {
  name               = "${local.resource_prefix}-processor-role"
  assume_role_policy = data.aws_iam_policy_document.processor_role.json
  tags               = var.service_tags
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

resource "aws_iam_policy" "ec2_create_network_int" {
  name   = "${local.resource_prefix}-ec2-create-network-policy"
  policy = data.aws_iam_policy_document.ec2_create_network_int.json
}

data "aws_iam_policy_document" "ec2_create_network_int" {
  statement {
    actions = [
      "EC2:CreateNetworkInterface",
      "EC2:DescribeNetworkInterfaces",
      "EC2:DeleteNetworkInterface"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach_ec2_create_network_int" {
  role       = aws_iam_role.processor_role.name
  policy_arn = aws_iam_policy.ec2_create_network_int.arn
}

resource "aws_iam_policy" "send_message_to_next_queue" {
  count  = length(var.output_queue_arns) >= 1 ? 1 : 0
  name   = "${local.resource_prefix}-send-message-to-next-queue-policy"
  policy = data.aws_iam_policy_document.send_message_to_next_queue.json
}

data "aws_iam_policy_document" "send_message_to_next_queue" {
  statement {
    actions = [
      "sqs:SendMessage"
    ]

    resources = var.output_queue_arns
  }
}

resource "aws_iam_role_policy_attachment" "attach_send_message_to_next_queue" {
  count      = length(var.output_queue_arns) >= 1 ? 1 : 0
  role       = aws_iam_role.processor_role.name
  policy_arn = aws_iam_policy.send_message_to_next_queue[0].arn
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_basic_execution_role_policy" {
  role       = aws_iam_role.processor_role.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
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
    actions   = ["sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
    effect    = "Allow"
    resources = [aws_sqs_queue.input_queue.arn]
  }
}
