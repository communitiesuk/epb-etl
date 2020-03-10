module "extract_stage" {
  source = "./stage"
  handler = {
    actual_sha256 = data.remotefile_read.handler.actual_sha256
    s3_bucket     = aws_s3_bucket.s3_deployment_artefacts.bucket
    s3_key        = aws_s3_bucket_object.handler.key
  }
  layers = {
    libs = {
      actual_sha256 = data.remotefile_read.lib_layer.actual_sha256
      s3_bucket     = aws_s3_bucket.s3_deployment_artefacts.bucket
      s3_key        = aws_s3_bucket_object.lib_layer.key
    }
  }
  service_tags = var.service_tags
  stage        = "extract"
  input_roles  = [aws_iam_role.trigger_role.arn]
  vpc_config   = var.extract_vpc_config
  environment  = var.extract_environment
}

module "transform_stage" {
  source = "./stage"
  handler = {
    actual_sha256 = data.remotefile_read.handler.actual_sha256
    s3_bucket     = aws_s3_bucket.s3_deployment_artefacts.bucket
    s3_key        = aws_s3_bucket_object.handler.key
  }
  layers = {
    libs = {
      actual_sha256 = data.remotefile_read.lib_layer.actual_sha256
      s3_bucket     = aws_s3_bucket.s3_deployment_artefacts.bucket
      s3_key        = aws_s3_bucket_object.lib_layer.key
    }
  }
  service_tags = var.service_tags
  stage        = "transform"
  input_roles  = [module.extract_stage.processor_role]
  environment  = var.transform_environment
}

module "load_stage" {
  source = "./stage"
  handler = {
    actual_sha256 = data.remotefile_read.handler.actual_sha256
    s3_bucket     = aws_s3_bucket.s3_deployment_artefacts.bucket
    s3_key        = aws_s3_bucket_object.handler.key
  }
  layers = {
    libs = {
      actual_sha256 = data.remotefile_read.lib_layer.actual_sha256
      s3_bucket     = aws_s3_bucket.s3_deployment_artefacts.bucket
      s3_key        = aws_s3_bucket_object.lib_layer.key
    }
  }
  service_tags = var.service_tags
  stage        = "load"
  input_roles  = [module.transform_stage.processor_role]
  environment  = var.load_environment
}
