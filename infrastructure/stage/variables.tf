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
    id            = string
    local_path    = string
    source        = string
  })
}

variable "layers" {
  description = "A list of layers that will be loaded onto the lambda execution environment"
  default     = {}
  type = map(
    object({
      actual_sha256 = string
      id            = string
      local_path    = string
      source        = string
    })
  )
}

locals {
  resource_prefix = "${var.service_tags.Application}-${var.service_tags.Environment}-${var.stage}"
}
