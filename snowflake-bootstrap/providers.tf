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
  # account_name/organization_name are hardcoded to avoid the deprecated
  # SNOWFLAKE_ACCOUNT env var which requires experimental feature flags in v2.x.
  # SNOWFLAKE_USER and snowflake_private_key are still read from the workspace.
  organization_name = "EQKUHCN"
  account_name      = "IE18493"
  role              = "ACCOUNTADMIN"
  authenticator     = "SNOWFLAKE_JWT"
  private_key       = var.snowflake_private_key

  preview_features_enabled = [
    "snowflake_sequence_resource",
    "snowflake_table_resource"
  ]
}
