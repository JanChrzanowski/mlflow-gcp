###############################################################################
# Module: service_account
# Dedicated MLflow service account with least-privilege IAM bindings
###############################################################################

resource "google_service_account" "mlflow" {
  project      = var.project_id
  account_id   = "${var.prefix}-mlflow-sa"
  display_name = "MLflow Tracking Server Service Account"
  description  = "Used by Cloud Run MLflow service to access Cloud SQL and GCS"
}

# ── Artifact Registry — pull Docker image ─────────────────────────────────────
resource "google_project_iam_member" "artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.mlflow.email}"
}

# ── Cloud SQL client ───────────────────────────────────────────────────────────
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.mlflow.email}"
}

# ── Secret Manager (DB password + MLflow admin password) ──────────────────────
resource "google_secret_manager_secret_iam_member" "db_password" {
  project   = var.project_id
  secret_id = var.db_password_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.mlflow.email}"
}

resource "google_secret_manager_secret_iam_member" "mlflow_admin_password" {
  project   = var.project_id
  secret_id = var.admin_password_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.mlflow.email}"
}

# ── Observability ──────────────────────────────────────────────────────────────
resource "google_project_iam_member" "metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.mlflow.email}"
}

resource "google_project_iam_member" "log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.mlflow.email}"
}
