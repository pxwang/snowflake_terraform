# Create the primary data warehouse database
output "database_name" {
  value       = snowflake_database.this.name
  description = "The fully qualified tracking name of the created database"
}

output "database_role_name" {
  value       = snowflake_database_role.db_reader.name
  description = "The specific database role associated with this dataset"
}
