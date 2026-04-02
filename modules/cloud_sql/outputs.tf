output "connection_name" {
  description = "Cloud SQL instance connection name (project:region:instance)"
  value       = data.google_sql_database_instance.maindb.connection_name
}

output "database_name" {
  description = "Name of the created MLflow database"
  value       = google_sql_database.mlflow.name
}

output "db_user" {
  description = "PostgreSQL user for MLflow"
  value       = google_sql_user.mlflow.name
}

output "db_password_secret_id" {
  description = "Secret Manager secret ID holding the DB password"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "db_password_secret_version" {
  description = "Full resource name of the secret version"
  value       = google_secret_manager_secret_version.db_password.name
}

output "backend_store_uri_template" {
  description = "MLflow backend store URI — substitute CONNECTION_NAME at deploy time"
  value       = "postgresql+psycopg2://${google_sql_user.mlflow.name}:DB_PASSWORD@/${google_sql_database.mlflow.name}?host=/cloudsql/${data.google_sql_database_instance.maindb.connection_name}"
  sensitive   = false
}
