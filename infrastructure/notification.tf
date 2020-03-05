resource "aws_sns_topic" "trigger_etl" {
  name = "${local.resource_prefix}-trigger-notifications"
  tags = var.service_tags
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = aws_sns_topic.trigger_etl.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.trigger.arn
}
