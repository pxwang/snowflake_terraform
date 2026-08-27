terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.19.0"
    }
  }

  backend "remote" {
    organization = "air_space"

    workspaces {
      name = "gh-actions-demo"
    }
  }
}


provider "snowflake" {
  # Key-pair (RSA JWT) authentication instead of username/password.
  # Nothing sensitive is committed to source control:
  #   SNOWFLAKE_ACCOUNT                - Snowflake account identifier (env var)
  #   SNOWFLAKE_USER                   - Service account used by Terraform (env var)
  #   SNOWFLAKE_PRIVATE_KEY_PASSPHRASE - Passphrase for the private key, if encrypted (env var, optional)
  #
  # The private key is passed explicitly (var.snowflake_private_key) rather
  # than left to the SNOWFLAKE_PRIVATE_KEY env var: HCP Terraform's
  # "Environment Variable" category rejects values containing newlines, and
  # a PEM key is always multi-line. Set snowflake_private_key as a
  # "Terraform variable" (sensitive) in the workspace instead. When left
  # unset (null), the provider falls back to reading SNOWFLAKE_PRIVATE_KEY
  # from the environment as before.
  authenticator = "SNOWFLAKE_JWT"
  private_key   = var.snowflake_private_key

  preview_features_enabled = [
    "snowflake_sequence_resource",
    "snowflake_table_resource"
  ]
}