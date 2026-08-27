variable "environment" {
  type        = string
  description = "The target deployment environment (e.g., dev, prod)"
}

variable "snowflake_private_key" {
  type        = string
  description = <<-EOT
    PEM-encoded RSA private key for Snowflake key-pair (JWT) auth.
    Set this as an HCP Terraform "Terraform variable" (not "Environment
    Variable") so the multi-line PEM content is accepted - the Environment
    Variable category rejects values containing newlines. Leave unset to
    fall back to the SNOWFLAKE_PRIVATE_KEY environment variable instead.
  EOT
  default     = null
  sensitive   = true
}