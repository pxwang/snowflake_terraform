terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 1.0"
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
}

resource "snowflake_database" "demo_db" {
  name    = "DEMO_DB"
  comment = "Database for Snowflake Terraform demo"
}

# Create the Snowflake Schema inside the database above
resource "snowflake_schema" "analytics_schema" {
  database = snowflake_database.demo_db.name
  name     = "ANALYTICS"
  comment  = "Analytics schema managed by Terraform"

  # Optional settings
  is_transient        = false
  with_managed_access = false
}

resource "snowflake_sequence" "sequence" {
  database = snowflake_database.demo_db.name
  schema   = snowflake_schema.analytics_schema.name
  name     = "sequence"
}

resource "snowflake_table" "table" {
  database                    = snowflake_database.demo_db.name
  schema                      = snowflake_schema.analytics_schema.name
  name                        = "TABLE_DM"
  comment                     = "A table."
  cluster_by                  = ["to_date(DATE)"]
  data_retention_time_in_days = 1
  change_tracking             = false

  column {
    name     = "ID"
    type     = "int"
    nullable = true
  }

  column {
    name     = "IDENTITY"
    type     = "NUMBER(38,0)"
    nullable = true

    identity {
      start_num = 1
      step_num  = 3
    }
  }

  column {
    name     = "DATA_1"
    type     = "text"
    nullable = false
    collate  = "en-ci"
  }

  column {
    name = "DATE"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name    = "EXTRA"
    type    = "VARIANT"
    comment = "extra data"
  }
}