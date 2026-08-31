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
  # Identical to the main project provider. Charlie1's default role is
  # ACCOUNTADMIN so no role override is needed — the bootstrap workspace
  # uses the same env vars as gh-actions-demo (SNOWFLAKE_ACCOUNT_NAME,
  # SNOWFLAKE_ORGANIZATION_NAME, SNOWFLAKE_USER, snowflake_private_key).
  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key

  preview_features_enabled = [
    "snowflake_sequence_resource",
    "snowflake_table_resource"
  ]
}
