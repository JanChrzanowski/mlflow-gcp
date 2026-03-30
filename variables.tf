###############################################################################
# Root variables — set values in terraform.tfvars
###############################################################################

# ── Project ────────────────────────────────────────────────────────────────────
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region for all resources except Cloud Run (Secret Manager, GCS, etc.)"
  type        = string
  default     = "europe-central2"
}

variable "cloud_run_region" {
  description = "Region for Cloud Run service — must support custom domain mapping (europe-west1 does, europe-central2 does not)"
  type        = string
  default     = "europe-west1"
}

variable "gcs_location" {
  description = "GCS bucket location (multi-region or region, e.g. EU, US, europe-central2)"
  type        = string
  default     = "europe-central2"
}

# ── Naming ─────────────────────────────────────────────────────────────────────
variable "prefix" {
  description = "Short prefix applied to all resource names (e.g. 'acme' → 'acme-mlflow-sa')"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,18}[a-z0-9]$", var.prefix))
    error_message = "prefix must be 3-20 lowercase letters, digits, or hyphens and start/end with a letter or digit."
  }
}

# ── Cloud SQL ──────────────────────────────────────────────────────────────────
variable "cloudsql_instance_name" {
  description = "Name of the existing Cloud SQL instance"
  type        = string
  default     = "maindb"
}

variable "mlflow_db_name" {
  description = "Database name to create inside Cloud SQL"
  type        = string
  default     = "mlflow"
}

variable "mlflow_db_user" {
  description = "PostgreSQL user for MLflow"
  type        = string
  default     = "mlflow"
}

# ── MLflow auth ────────────────────────────────────────────────────────────────
variable "mlflow_admin_username" {
  description = "MLflow admin username (full MANAGE access)"
  type        = string
  default     = "admin"
}

variable "mlflow_demo_username" {
  description = "MLflow demo user username (READ + EDIT access)"
  type        = string
  default     = "demo_user"
}

# ── Cloud Run ──────────────────────────────────────────────────────────────────
variable "mlflow_image" {
  description = "Full Docker image URI for the MLflow server"
  type        = string
  # Example: europe-docker.pkg.dev/my-project/mlflow-repo/mlflow:2.16.0
}

variable "cloud_run_min_instances" {
  description = "Minimum Cloud Run instances (1 avoids cold starts)"
  type        = number
  default     = 1
}

variable "cloud_run_max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 3
}

variable "cloud_run_cpu" {
  description = "CPU limit per Cloud Run container"
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Memory limit per Cloud Run container"
  type        = string
  default     = "512Mi"
}
