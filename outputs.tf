output "mlflow_url" {
  description = "Public HTTPS URL of the MLflow Tracking Server"
  value       = module.cloud_run.service_url
}

output "artifact_bucket" {
  description = "GCS artifact store URL"
  value       = module.gcs.bucket_url
}

output "cloudsql_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = module.cloud_sql.connection_name
}

output "service_account_email" {
  description = "MLflow service account e-mail"
  value       = module.service_account.email
}

output "mlflow_admin_secret" {
  description = "Secret Manager resource name for the MLflow admin password"
  value       = google_secret_manager_secret.mlflow_admin_password.name
}

output "mlflow_demo_secret" {
  description = "Secret Manager resource name for the MLflow demo password"
  value       = google_secret_manager_secret.mlflow_demo_password.name
}

output "retrieve_admin_password_cmd" {
  description = "gcloud command to retrieve the admin password"
  value       = "gcloud secrets versions access latest --secret=${google_secret_manager_secret.mlflow_admin_password.secret_id} --project=${var.project_id}"
}
