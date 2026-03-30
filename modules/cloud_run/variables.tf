variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "region" {
  description = "Cloud Run deployment region"
  type        = string
}

variable "image" {
  description = "Full Docker image URI (e.g. europe-docker.pkg.dev/PROJECT/REPO/mlflow:latest)"
  type        = string
}

variable "service_account_email" {
  description = "Service account e-mail for the Cloud Run service"
  type        = string
}

variable "cloudsql_connection_name" {
  description = "Cloud SQL instance connection name (project:region:instance)"
  type        = string
}

variable "db_user" {
  description = "PostgreSQL user for MLflow"
  type        = string
  default     = "mlflow"
}

variable "db_name" {
  description = "PostgreSQL database name for MLflow"
  type        = string
  default     = "mlflow"
}

variable "db_password_secret_id" {
  description = "Secret Manager secret ID for the DB password"
  type        = string
}

variable "admin_password_secret_id" {
  description = "Secret Manager secret ID for the MLflow admin password"
  type        = string
}

variable "demo_password_secret_id" {
  description = "Secret Manager secret ID for the MLflow demo_user password"
  type        = string
}

variable "mlflow_admin_username" {
  description = "MLflow admin username"
  type        = string
  default     = "admin"
}

variable "mlflow_demo_username" {
  description = "MLflow demo user username"
  type        = string
  default     = "demo_user"
}

variable "kek_passphrase_secret_id" {
  description = "Secret Manager secret ID for MLFLOW_CRYPTO_KEK_PASSPHRASE (AI Gateway encryption)"
  type        = string
}

variable "artifact_bucket_name" {
  description = "GCS bucket name for MLflow artifacts"
  type        = string
}

variable "min_instances" {
  description = "Minimum Cloud Run instances (set to 1 to avoid cold starts)"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 5
}

variable "cpu" {
  description = "CPU limit for each container"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory limit for each container"
  type        = string
  default     = "512Mi"
}

variable "gunicorn_workers" {
  description = "Gunicorn worker count inside the MLflow container"
  type        = number
  default     = 2
}
