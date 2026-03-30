variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix, e.g. 'myco-mlflow'"
  type        = string
}

variable "db_password_secret_id" {
  description = "Secret Manager secret ID holding the MLflow DB user password"
  type        = string
}

variable "admin_password_secret_id" {
  description = "Secret Manager secret ID holding the MLflow basic-auth admin password"
  type        = string
}
