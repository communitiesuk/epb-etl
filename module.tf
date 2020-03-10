module "etl_pipeline" {
  source                = "./infrastructure"
  service_tags          = var.service_tags
  trigger_vpc_config    = var.trigger_vpc_config
  trigger_environment   = var.trigger_environment
  extract_vpc_config    = var.extract_vpc_config
  extract_environment   = var.extract_environment
  transform_environment = var.transform_environment
  load_environment      = var.load_environment
}

variable "service_tags" {
  description = "Tags for each resource in the service"
  type = object({
    Application = string
    Environment = string
  })
}

variable "trigger_vpc_config" {
  description = "Specific VPCs the trigger stage should connect to"
  type = object({
    subnet_ids         = list(string),
    security_group_ids = list(string),
  })
  default = {
    subnet_ids         = [],
    security_group_ids = [],
  }
}

variable "trigger_environment" {
  description = "The environment variables used by the trigger stage"
}

variable "extract_vpc_config" {
  description = "Specific VPCs the extract stage should connect to"
  type = object({
    subnet_ids         = list(string),
    security_group_ids = list(string),
  })
  default = {
    subnet_ids         = [],
    security_group_ids = [],
  }
}

variable "extract_environment" {
  description = "The environment variables used by the extract stage"
}

variable "transform_environment" {
  description = "The environment variables used by the load stage"
}

variable "load_environment" {
  description = "The environment variables used by the load stage"
}
