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
  # Credentials are supplied via environment variables so nothing sensitive
  # is committed to source control:
  #   SNOWFLAKE_ACCOUNT                - Snowflake account identifier
  #   SNOWFLAKE_USER                   - Service account used by Terraform
  #   SNOWFLAKE_PRIVATE_KEY            - PEM-encoded RSA private key (unencrypted or PKCS8)
  #   SNOWFLAKE_PRIVATE_KEY_PASSPHRASE - Passphrase for the private key (optional, if encrypted)
  authenticator = "SNOWFLAKE_JWT"

  preview_features_enabled = [
    "snowflake_sequence_resource",
    "snowflake_table_resource"
  ]
}