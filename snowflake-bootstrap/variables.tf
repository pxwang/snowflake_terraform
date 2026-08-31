variable "snowflake_private_key" {
  type        = string
  description = <<-EOT
    PEM-encoded RSA private key for Snowflake key-pair (JWT) auth.
    Set this as an HCP Terraform "Terraform variable" (sensitive) in the
    gh-actions-bootstrap workspace.
  EOT
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Target deployment environment (dev, prod). Used to name monitors."
  default     = "dev"
}
