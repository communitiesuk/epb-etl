data "local_file" "handler" {
  filename = "${path.module}/../dist/handler.zip"
}

data "local_file" "lib_layer" {
  filename = "${path.module}/../dist/lib-layer.zip"
}

resource "aws_s3_bucket" "s3_deployment_artefacts" {
  bucket        = "${local.resource_prefix}-deployment"
  acl           = "private"
  tags          = var.service_tags
  force_destroy = true
}

resource "aws_s3_bucket_object" "handler" {
  bucket = aws_s3_bucket.s3_deployment_artefacts.bucket
  key    = "handler-${filebase64sha256(data.local_file.handler.filename)}.zip"
  source = data.local_file.handler.filename
  acl    = "private"
  tags   = var.service_tags
}

resource "aws_s3_bucket_object" "lib_layer" {
  bucket = aws_s3_bucket.s3_deployment_artefacts.bucket
  key    = "lib-layer-${filebase64sha256(data.local_file.lib_layer.filename)}.zip"
  source = data.local_file.lib_layer.filename
  acl    = "private"
  tags   = var.service_tags
}
