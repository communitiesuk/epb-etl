data "remotefile_read" "handler" {
  source = "file://${abspath(path.module)}/../dist/handler.zip"
}

data "remotefile_read" "lib_layer" {
  source = "file://${abspath(path.module)}/../dist/lib-layer.zip"
}

resource "aws_s3_bucket" "s3_deployment_artefacts" {
  bucket = "${local.resource_prefix}-deployment"
  acl    = "private"
  tags   = var.service_tags
  force_destroy = true
}

resource "aws_s3_bucket_object" "handler" {
  bucket = aws_s3_bucket.s3_deployment_artefacts.bucket
  key    = "handler-${data.remotefile_read.handler.actual_sha256}.zip"
  source = data.remotefile_read.handler.local_path
  acl    = "private"
  tags   = var.service_tags
}

resource "aws_s3_bucket_object" "lib_layer" {
  bucket = aws_s3_bucket.s3_deployment_artefacts.bucket
  key    = "lib-layer-${data.remotefile_read.lib_layer.actual_sha256}.zip"
  source = data.remotefile_read.lib_layer.local_path
  acl    = "private"
  tags   = var.service_tags
}
