# ==============================================================================
# BOOTSTRAP / FOUNDATION RESOURCES
#
# This project runs as ACCOUNTADMIN and owns resources that TF_ADMIN_ROLE
# cannot create. All other infrastructure lives in the root project.
#
# Run this pipeline manually (workflow_dispatch) or on changes to this
# directory. Changes here are rare and high-impact — review carefully.
# ==============================================================================

# Resource monitor for the example analytics warehouse (examples.tf).
resource "snowflake_resource_monitor" "analytics_wh_monitor" {
  name                      = "ANALYTICS_WH_MONITOR"
  credit_quota              = 100
  frequency                 = "DAILY"
  start_timestamp           = "IMMEDIATELY"
  notify_triggers           = [75]
  suspend_trigger           = 90
  suspend_immediate_trigger = 100
}

# Resource monitor for the module-managed warehouse (main.tf).
resource "snowflake_resource_monitor" "analytics_wh_env_monitor" {
  name                      = "ANALYTICS_WH_${upper(var.environment)}_MONITOR"
  credit_quota              = var.environment == "prod" ? 500 : 50
  frequency                 = "MONTHLY"
  start_timestamp           = "IMMEDIATELY"
  notify_triggers           = [75]
  suspend_trigger           = 90
  suspend_immediate_trigger = 100
}
