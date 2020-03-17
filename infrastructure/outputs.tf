output "trigger_sns_topic_url" {
  value = aws_sns_topic.trigger_etl.id
}
