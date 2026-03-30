variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "instance_name" {
  description = "Name of the existing Cloud SQL instance"
  type        = string
  default     = "maindb"
}

variable "database_name" {
  description = "Name of the database to create inside the Cloud SQL instance"
  type        = string
  default     = "mlflow"
}

variable "db_user" {
  description = "PostgreSQL user created for MLflow"
  type        = string
  default     = "mlflow"
}

variable "labels" {
  description = "Labels applied to Secret Manager secrets"
  type        = map(string)
  default     = {}
}
