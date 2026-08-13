
# Create a compute warehouse
resource "snowflake_warehouse" "analytics_wh" {
  name           = "ANALYTICS_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60 # Automatically shuts down after 1 minute of inactivity to save costs
  auto_resume    = true
}

# Create a data warehouse database
resource "snowflake_database" "prod_db" {
  name    = "PROD_DB"
  comment = "Production Database Managed by Terraform"
}

# Create a schema inside the database
resource "snowflake_schema" "sales_schema" {
  database = snowflake_database.prod_db.name
  name     = "SALES"
}

# Create a dedicated custom role for Data Analysts
resource "snowflake_database_role" "analyst_role" {
  database   = "PROD_DB"
  name       = "DATA_ANALYST_ROLE"
  comment    = "Role for business intelligence and data analysis tasks"
  depends_on = [snowflake_database.prod_db]
}

# Create a clean Account Role for system/compute context
resource "snowflake_account_role" "compute_consumer" {
  name    = "COMPUTE_CONSUMER_ROLE"
  comment = "Account role used to bind warehouse usage to database users"
}


# Grant usage privileges on the warehouse to the ACCOUNT role
resource "snowflake_grant_privileges_to_account_role" "wh_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.compute_consumer.name

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.analytics_wh.name
  }
}

# Link the Database Role to the Account Role (Role Hierarchy)
resource "snowflake_grant_database_role" "link_roles" {
  database_role_name = snowflake_database_role.analyst_role.fully_qualified_name
  parent_role_name   = snowflake_account_role.compute_consumer.name
}


# Grant usage privileges on the database
resource "snowflake_grant_privileges_to_account_role" "db_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.compute_consumer.fully_qualified_name
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.prod_db.name
  }
}

# Grant read-only access (Usage) to the specific schema
resource "snowflake_grant_privileges_to_account_role" "schema_grant" {
  privileges        = ["USAGE"]
  account_role_name = snowflake_account_role.compute_consumer.fully_qualified_name
  on_schema {
    schema_name = "\"${snowflake_database.prod_db.name}\".\"${snowflake_schema.sales_schema.name}\""
  }
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
  # Enforces a hard error inside CI/CD if an operation attempts to drop this table
  lifecycle {
    prevent_destroy = true
  }
}

# Create a compute warehouse with modules 
# Variable environment as suffix example ANALYTICS_WH_DEV or ANALYTICS_WH_PROD
module "snowflake_warehouse" {
  # 1. Look up where the blueprint lives
  source = "./modules/warehouses"

  # 2. Feed values into the module's input variables
  warehouse_name = "ANALYTICS_WH"
  environment    = var.environment
  warehouse_size = var.environment == "prod" ? "MEDIUM" : "XSMALL"
}

# Create a data with modules 
module "sales_database" {
  source = "./modules/databases"

  # Pass lowercase, matching case-sensitive variables exactly
  database_name       = "sales"
  environment         = var.environment
  data_retention_days = 2

  # Provision multiple schemas at once using an array list
  schema_names = ["raw", "staging", "analytics"]
}
