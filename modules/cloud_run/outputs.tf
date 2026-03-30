output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.mlflow.name
}

output "service_url" {
  description = "Public HTTPS URL of the MLflow Tracking Server"
  value       = google_cloud_run_v2_service.mlflow.uri
}

output "service_id" {
  description = "Cloud Run service resource ID"
  value       = google_cloud_run_v2_service.mlflow.id
}

output "latest_revision" {
  description = "Latest ready revision name"
  value       = google_cloud_run_v2_service.mlflow.latest_ready_revision
}
