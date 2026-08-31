# ==============================================================================
# REAL INFRASTRUCTURE (module-based)
#
# See examples.tf for the hand-written illustrative resources instead.
# ==============================================================================

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
