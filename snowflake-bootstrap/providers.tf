terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.19.0"
    }
  }

  # Separate workspace from the main project so ACCOUNTADMIN credentials
  # are isolated and never shared with day-to-day Terraform runs.
  backend "remote" {
    organization = "air_space"

    workspaces {
      name = "gh-actions-bootstrap"
    }
  }
}

provider "snowflake" {
  # Same provider config as the main project — role is set via
  # SNOWFLAKE_ROLE=ACCOUNTADMIN environment variable in the HCP Terraform
  # gh-actions-bootstrap workspace.
  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key

  preview_features_enabled = [
    "snowflake_sequence_resource",
    "snowflake_table_resource"
  ]
}
