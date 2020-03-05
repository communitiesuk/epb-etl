resource "aws_lambda_function" "trigger" {
  function_name    = "${local.resource_prefix}-trigger-processor"
  role             = aws_iam_role.trigger_role.arn
  handler          = "lib/bootstrap.handler"
  source_code_hash = base64encode(data.remotefile_read.handler.actual_sha256)
  runtime          = "ruby2.7"
  tags             = var.service_tags
  timeout          = 900
  layers           = [aws_lambda_layer_version.lib_layer.arn]
  s3_bucket        = aws_s3_bucket.s3_deployment_artefacts.bucket
  s3_key           = aws_s3_bucket_object.handler.key

  environment {
    variables = {
      ETL_STAGE = "trigger"
    }
  }
}

resource "aws_lambda_layer_version" "lib_layer" {
  layer_name       = "${local.resource_prefix}-trigger-processor-lib-layer"
  s3_bucket        = aws_s3_bucket.s3_deployment_artefacts.bucket
  s3_key           = aws_s3_bucket_object.lib_layer.key
  source_code_hash = base64encode(data.remotefile_read.lib_layer.actual_sha256)
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.trigger_etl.arn
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

