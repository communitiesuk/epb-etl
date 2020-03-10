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
    subnet_ids = list(string),
    security_group_ids= list(string),
  })
  default = {
    subnet_ids = [],
    security_group_ids= [],
  }
}

variable "extract_vpc_config" {
  description = "Specific VPCs the extract stage should connect to"
  type = object({
    subnet_ids = list(string),
    security_group_ids= list(string),
  })
  default = {
    subnet_ids = [],
    security_group_ids= [],
  }
}

locals {
  resource_prefix = "${var.service_tags.Application}-${var.service_tags.Environment}"
}
