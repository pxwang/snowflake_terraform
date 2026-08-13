# Create the primary data warehouse database
resource "snowflake_database" "this" {
  name                        = "${upper(var.database_name)}_DB_${upper(var.environment)}"
  data_retention_time_in_days = var.environment == "prod" ? var.data_retention_days : 1
  comment                     = "Managed by Terraform. Environment: ${var.environment}"
}

# Automatically loop through and spin up all requested schemas
resource "snowflake_schema" "this" {
  for_each = toset(var.schema_names)

  database = snowflake_database.this.name
  name     = upper(each.value)
  comment  = "Schema managed by Terraform inside ${snowflake_database.this.name}"
}

# Create an application/functional role scoped purely to this database
resource "snowflake_database_role" "db_reader" {
  database = snowflake_database.this.name
  name     = "${upper(var.database_name)}_READER_ROLE"
  comment  = "Read-only access database role for ${snowflake_database.this.name}"

  # Safety safeguard ensuring the database fully exists first
  depends_on = [snowflake_database.this]
}

# ==============================================================================
# AUTOMATIC PRIVILEGE GRANTS
# ==============================================================================

# Step 1: Grant USAGE on the entire Database to the database role
resource "snowflake_grant_privileges_to_database_role" "database_usage" {
  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.db_reader.name}\""
  privileges         = ["USAGE"]
  on_database = snowflake_database.this.name
}

# Step 2: Grant USAGE on all schemas inside the database to the database role
resource "snowflake_grant_privileges_to_database_role" "schema_usage" {
  for_each = snowflake_schema.this

  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.db_reader.name}\""
  privileges         = ["USAGE"]

  on_schema {
    # Properly formats the schema identifier string
    schema_name = "\"${snowflake_database.this.name}\".\"${each.value.name}\""
  }
}

# Step 3: Grant SELECT on future tables so new data is readable automatically
resource "snowflake_grant_privileges_to_database_role" "future_tables_select" {
  for_each = snowflake_schema.this

  database_role_name = "\"${snowflake_database.this.name}\".\"${snowflake_database_role.db_reader.name}\""
  privileges         = ["SELECT"]

  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "\"${snowflake_database.this.name}\".\"${each.value.name}\""
    }
  }
}