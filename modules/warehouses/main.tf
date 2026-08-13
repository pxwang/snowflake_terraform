resource "snowflake_warehouse" "this" {
  name           = "${var.warehouse_name}_${upper(var.environment)}"
  warehouse_size = var.warehouse_size
  auto_suspend   = 60
  auto_resume    = true
}