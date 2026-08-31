# ==============================================================================
# BOOTSTRAP / FOUNDATION RESOURCES
#
# This project runs as ACCOUNTADMIN and owns all resources that require
# elevated privileges — warehouses (resource_monitor attachment needs
# ACCOUNTADMIN) and resource monitors (CREATE RESOURCE MONITOR needs
# ACCOUNTADMIN). All other infrastructure lives in the root project.
#
# Run this pipeline manually (workflow_dispatch) or on changes to this
# directory. Changes here are rare and high-impact — review carefully.
# ==============================================================================

# ---------------------------------------------------------------------------
# Resource monitors
# ---------------------------------------------------------------------------

resource "snowflake_resource_monitor" "analytics_wh_monitor" {
  name                      = "ANALYTICS_WH_MONITOR"
  credit_quota              = 100
  frequency                 = "DAILY"
  start_timestamp           = "IMMEDIATELY"
  notify_triggers           = [75]
  suspend_trigger           = 90
  suspend_immediate_trigger = 100
}

resource "snowflake_resource_monitor" "analytics_wh_env_monitor" {
  name                      = "ANALYTICS_WH_${upper(var.environment)}_MONITOR"
  credit_quota              = var.environment == "prod" ? 500 : 50
  frequency                 = "MONTHLY"
  start_timestamp           = "IMMEDIATELY"
  notify_triggers           = [75]
  suspend_trigger           = 90
  suspend_immediate_trigger = 100
}

# ---------------------------------------------------------------------------
# Warehouses (owned here so resource_monitor can be set by ACCOUNTADMIN)
# ---------------------------------------------------------------------------


resource "snowflake_warehouse" "analytics_wh" {
  name             = "ANALYTICS_WH"
  warehouse_size   = "XSMALL"
  auto_suspend     = 60
  auto_resume      = true
  resource_monitor = snowflake_resource_monitor.analytics_wh_monitor.name
}

resource "snowflake_warehouse" "analytics_wh_env" {
  name             = "ANALYTICS_WH_${upper(var.environment)}"
  warehouse_size   = var.environment == "prod" ? "MEDIUM" : "XSMALL"
  auto_suspend     = 60
  auto_resume      = true
  resource_monitor = snowflake_resource_monitor.analytics_wh_env_monitor.name
}
