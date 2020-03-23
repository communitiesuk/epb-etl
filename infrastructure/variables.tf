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
  description = "The environment variables used by the extract stage"
}

variable "load_environment" {
  description = "The environment variables used by the load stage"
}

variable "extract_max_queue_receive_count" {
  description = "The max number of times the consumer of the source queue receives a message for the extract stage"
  default     = 1
  type        = number
}

variable "extract_reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function for the extract stage"
  default     = -1
  type        = number
}

variable "transform_max_queue_receive_count" {
  description = "The max number of times the consumer of the source queue receives a message for the transform stage"
  default     = 1
  type        = number
}

variable "transform_reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function for the transform stage"
  default     = -1
  type        = number
}

variable "load_max_queue_receive_count" {
  description = "The max number of times the consumer of the source queue receives a message for the load stage"
  default     = 1
  type        = number
}

variable "load_reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function for the load stage"
  default     = -1
  type        = number
}

locals {
  resource_prefix = "${var.service_tags.Application}-${var.service_tags.Environment}"
}
