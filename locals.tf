locals {
  common_labels = {
    project     = var.project_id
    application = "mlflow"
    managed_by  = "terraform"
  }
}
