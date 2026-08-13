terraform {
  required_providers {
    snowflake = {
      # This explicitly forces the module to use the official Snowflake repository
      source  = "snowfakedb/snowflake"
      version = "~> 1.0"
    }
  }
}