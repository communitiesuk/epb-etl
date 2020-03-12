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
  service_tags      = var.service_tags
  stage             = "extract"
  vpc_config        = var.extract_vpc_config
  environment       = var.extract_environment
  output_queue_arns = [module.transform_stage.stage_input_queue_arn]
  output_queue_url  = module.transform_stage.stage_input_queue_url
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
  service_tags      = var.service_tags
  stage             = "transform"
  environment       = var.transform_environment
  output_queue_arns = [module.load_stage.stage_input_queue_arn]
  output_queue_url  = module.load_stage.stage_input_queue_url
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
  service_tags      = var.service_tags
  stage             = "load"
  environment       = var.load_environment
  output_queue_arns = []
  output_queue_url  = ""
}
