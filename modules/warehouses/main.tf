# Caps credit spend on this warehouse. auto_suspend only stops idle time -
# it does nothing to stop a single expensive or runaway query from burning
# credits while it's running.
resource "snowflake_resource_monitor" "this" {
  name                      = "${var.warehouse_name}_${upper(var.environment)}_MONITOR"
  credit_quota              = var.credit_quota
  frequency                 = var.monitor_frequency
  start_timestamp           = "IMMEDIATELY"
  notify_triggers           = var.notify_triggers
  notify_users              = var.notify_users
  suspend_trigger           = var.suspend_trigger
  suspend_immediate_trigger = var.suspend_immediate_trigger
}

resource "snowflake_warehouse" "this" {
  name             = "${var.warehouse_name}_${upper(var.environment)}"
  warehouse_size   = var.warehouse_size
  auto_suspend     = 60
  auto_resume      = true
  resource_monitor = snowflake_resource_monitor.this.name
}
