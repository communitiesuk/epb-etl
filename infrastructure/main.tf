data "remotefile_read" "handler" {
  source = "file://${abspath(path.module)}/../dist/handler.zip"
}

data "remotefile_read" "bundler_layer" {
  source = "file://${abspath(path.module)}/../dist/bundler-layer.zip"
}

module "extract_stage" {
  source  = "./stage"
  handler = data.remotefile_read.handler
  layers = {
    bundler = data.remotefile_read.bundler_layer
  }
  service_tags = var.service_tags
  stage        = "extract"
}

module "transform_stage" {
  source  = "./stage"
  handler = data.remotefile_read.handler
  layers = {
    bundler = data.remotefile_read.bundler_layer
  }
  service_tags = var.service_tags
  stage        = "transform"
}

module "load_stage" {
  source  = "./stage"
  handler = data.remotefile_read.handler
  layers = {
    bundler = data.remotefile_read.bundler_layer
  }
  service_tags = var.service_tags
  stage        = "load"
}
