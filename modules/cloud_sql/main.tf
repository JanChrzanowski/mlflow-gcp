data "google_sql_database_instance" "maindb" {
  project = var.project_id
  name    = var.instance_name
}

resource "google_sql_database" "mlflow" {
  project  = var.project_id
  instance = data.google_sql_database_instance.maindb.name
  name     = var.database_name
  charset  = "UTF8"
}

resource "random_password" "mlflow_db" {
  length           = 32
  special          = true
  override_special = "-_."
}

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "${var.prefix}-mlflow-db-password"

  replication {
    auto {}
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.mlflow_db.result
}

resource "google_sql_user" "mlflow" {
  project  = var.project_id
  instance = data.google_sql_database_instance.maindb.name
  name     = var.db_user
  password = random_password.mlflow_db.result

  deletion_policy = "ABANDON"
}
