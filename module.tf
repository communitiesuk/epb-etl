module "etl_pipeline" {
  source       = "./infrastructure"
  service_tags = var.service_tags
}

variable "service_tags" {
  description = "Tags for each resource in the service"
  type = object({
    Application = string
    Environment = string
  })
}
