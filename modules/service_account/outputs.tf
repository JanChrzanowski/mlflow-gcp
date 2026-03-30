output "email" {
  description = "Service account e-mail"
  value       = google_service_account.mlflow.email
}

output "name" {
  description = "Fully-qualified service account resource name"
  value       = google_service_account.mlflow.name
}

output "member" {
  description = "IAM member string — serviceAccount:<email>"
  value       = "serviceAccount:${google_service_account.mlflow.email}"
}
