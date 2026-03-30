variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "prefix" {
  description = "Resource name prefix; bucket name = <prefix>-mlflow-artifacts"
  type        = string
}

variable "location" {
  description = "GCS bucket location (multi-region or region)"
  type        = string
  default     = "EU"
}

variable "nearline_age_days" {
  description = "Days after which objects are moved to NEARLINE storage"
  type        = number
  default     = 30
}

variable "coldline_age_days" {
  description = "Days after which objects are moved to COLDLINE storage"
  type        = number
  default     = 90
}

variable "labels" {
  description = "Labels applied to the bucket"
  type        = map(string)
  default     = {}
}
