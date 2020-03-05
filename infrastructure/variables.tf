variable "service_tags" {
  description = "Tags for each resource in the service"
  type = object({
    Application = string
    Environment = string
  })
}

locals {
  resource_prefix = "${var.service_tags.Application}-${var.service_tags.Environment}"
}
