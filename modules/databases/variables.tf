variable "database_name" {
  type        = string
  description = "The base name of the database (e.g., CORE, SALES, FIN)"
}

variable "environment" {
  type        = string
  description = "Target deployment environment tier (dev, prod, staging)"
}

variable "schema_names" {
  type        = list(string)
  default     = ["PUBLIC"]
  description = "List of schemas to automatically provision inside this database"
}

variable "data_retention_days" {
  type        = number
  default     = 1
  description = "Time Travel data retention period in days (1 to 90)"
}
