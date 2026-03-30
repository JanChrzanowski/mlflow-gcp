output "bucket_name" {
  description = "GCS bucket name"
  value       = google_storage_bucket.artifacts.name
}

output "bucket_url" {
  description = "GCS bucket URL (gs://...)"
  value       = "gs://${google_storage_bucket.artifacts.name}"
}

output "self_link" {
  description = "GCS bucket self link"
  value       = google_storage_bucket.artifacts.self_link
}
