# ==============================================================================
# REAL INFRASTRUCTURE (module-based)
#
# See examples.tf for the hand-written illustrative resources instead.
# ==============================================================================

# Grants CREATE RESOURCE MONITOR to TF_ADMIN_ROLE using the ACCOUNTADMIN alias.
# Only this resource uses the elevated provider — all other resources stay on TF_ADMIN_ROLE.
resource "snowflake_grant_privileges_to_account_role" "tf_admin_resource_monitor" {
  provider          = snowflake.accountadmin
  privileges        = ["CREATE RESOURCE MONITOR"]
  account_role_name = "TF_ADMIN_ROLE"
  on_account        = true
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
  credit_quota   = var.environment == "prod" ? 500 : 50

  depends_on = [snowflake_grant_privileges_to_account_role.tf_admin_resource_monitor]
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
