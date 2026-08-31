variable "warehouse_name" {
  type        = string
  description = "The root name of the virtual warehouse"
}

variable "environment" {
  type        = string
  description = "The target deployment environment (e.g., dev, prod)"
}

variable "warehouse_size" {
  type        = string
  description = "Compute power tier (XSMALL, SMALL, MEDIUM, etc.)"
}


