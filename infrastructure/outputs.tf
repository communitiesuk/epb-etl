output "trigger_sns_topic_arn" {
  value = aws_sns_topic.trigger_etl.arn
}
