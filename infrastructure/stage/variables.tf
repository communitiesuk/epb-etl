variable "service_tags" {
  description = "Tags for each resource in the service"
  default     = {}
}

variable "stage" {
  description = "The stage of the ETL pipeline this processor relates to"
  type        = string
}

variable "handler" {
  description = "A remotefiles_read output of the zipped codebase that will be used as the handler code"
  type = object({
    actual_sha256 = string
    s3_bucket     = string
    s3_key        = string
  })
}

variable "layers" {
  description = "A list of layers that will be loaded onto the lambda execution environment"
  default     = {}
  type = map(
    object({
      actual_sha256 = string
      s3_bucket     = string
      s3_key        = string
    })
  )
}

variable "input_roles" {
  description = "The role arns that are allowed to publish a message to this stage's sqs queue"
  default     = []
  type        = list(string)
}

locals {
  resource_prefix = "${var.service_tags.Application}-${var.service_tags.Environment}-${var.stage}"
}
