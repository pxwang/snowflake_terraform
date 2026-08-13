terraform {
  required_providers {
    snowflake = {
      # This explicitly forces the module to use the official Snowflake repository
      source  = "snowflakedb/snowflake"
      version = "~> 2.19.0"
    }
  }
}