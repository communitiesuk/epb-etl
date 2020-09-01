resource "aws_lambda_function" "trigger" {
  function_name                  = "${local.resource_prefix}-trigger-processor"
  role                           = aws_iam_role.trigger_role.arn
  handler                        = "lib/bootstrap.handler"
  source_code_hash               = filebase64sha256(data.local_file.handler.filename)
  runtime                        = "ruby2.7"
  tags                           = var.service_tags
  timeout                        = 900
  layers                         = [aws_lambda_layer_version.lib_layer.arn]
  s3_bucket                      = aws_s3_bucket.s3_deployment_artefacts.bucket
  s3_key                         = aws_s3_bucket_object.handler.key
  reserved_concurrent_executions = var.trigger_reserved_concurrent_executions

  vpc_config {
    security_group_ids = var.trigger_vpc_config.security_group_ids
    subnet_ids         = var.trigger_vpc_config.subnet_ids
  }

  environment {
    variables = merge(var.trigger_environment, {
      ETL_STAGE    = "trigger"
      NEXT_SQS_URL = module.extract_stage.stage_input_queue_url
    })
  }
}

resource "aws_lambda_layer_version" "lib_layer" {
  layer_name       = "${local.resource_prefix}-trigger-processor-lib-layer"
  s3_bucket        = aws_s3_bucket.s3_deployment_artefacts.bucket
  s3_key           = aws_s3_bucket_object.lib_layer.key
  source_code_hash = filebase64sha256(data.local_file.lib_layer.filename)
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.trigger_etl.arn
}

resource "aws_iam_policy" "ec2_create_network_int" {
  name   = "${local.resource_prefix}-trigger-policy"
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

  statement {
    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      module.extract_stage.stage_input_queue_arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach_ec2_create_network_int" {
  role       = aws_iam_role.trigger_role.name
  policy_arn = aws_iam_policy.ec2_create_network_int.arn
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_basic_execution_role_policy" {
  role       = aws_iam_role.trigger_role.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role" "trigger_role" {
  name               = "${local.resource_prefix}-trigger-role"
  assume_role_policy = data.aws_iam_policy_document.trigger_role.json
  tags               = var.service_tags
}

data "aws_iam_policy_document" "trigger_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

