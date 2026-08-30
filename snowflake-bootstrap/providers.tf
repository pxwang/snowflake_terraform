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
  # Runs as ACCOUNTADMIN — required for CREATE RESOURCE MONITOR and other
  # account-level privileges not grantable to non-ACCOUNTADMIN roles.
  # Credentials are set via HCP Terraform workspace environment variables:
  #   SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PRIVATE_KEY_PASSPHRASE (optional)
  # The private key is passed via var.snowflake_private_key (sensitive Terraform variable).
  role          = "ACCOUNTADMIN"
  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key

  preview_features_enabled = [
    "snowflake_sequence_resource",
    "snowflake_table_resource"
  ]
}
