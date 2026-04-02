

resource "google_storage_bucket" "artifacts" {
  project  = var.project_id
  name     = "${var.prefix}-mlflow-artifacts"
  location = var.location

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = var.nearline_age_days
    }
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition {
      age = var.coldline_age_days
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  labels = var.labels
}

