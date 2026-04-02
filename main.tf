###############################################################################
# Root configuration — MLflow on GCP
#
# Calls four reusable modules:
#   1. gcs            — artifact bucket
#   2. cloud_sql      — mlflow database on existing maindb instance
#   3. service_account — dedicated SA with least-privilege IAM
#   4. cloud_run      — MLflow Tracking Server
###############################################################################

# ── Enable required APIs ───────────────────────────────────────────────────────
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com",
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# ── MLflow admin password (Secret Manager) ─────────────────────────────────────
resource "random_password" "mlflow_admin" {
  length           = 24
  special          = true
  override_special = "-_."
}

resource "google_secret_manager_secret" "mlflow_admin_password" {
  project   = var.project_id
  secret_id = "${var.prefix}-mlflow-admin-password"

  replication {
    auto {}
  }

  labels = local.common_labels

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "mlflow_admin_password" {
  secret      = google_secret_manager_secret.mlflow_admin_password.id
  secret_data = random_password.mlflow_admin.result
}

# ── MLflow demo_user password (Secret Manager) ────────────────────────────────
resource "random_password" "mlflow_demo" {
  length           = 24
  special          = true
  override_special = "-_."
}

resource "google_secret_manager_secret" "mlflow_demo_password" {
  project   = var.project_id
  secret_id = "${var.prefix}-mlflow-demo-password"

  replication {
    auto {}
  }

  labels = local.common_labels

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "mlflow_demo_password" {
  secret      = google_secret_manager_secret.mlflow_demo_password.id
  secret_data = random_password.mlflow_demo.result
}

# ── AI Gateway encryption passphrase ──────────────────────────────────────────
resource "random_password" "mlflow_kek" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "mlflow_kek" {
  project   = var.project_id
  secret_id = "${var.prefix}-mlflow-kek-passphrase"

  replication {
    auto {}
  }

  labels     = local.common_labels
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "mlflow_kek" {
  secret      = google_secret_manager_secret.mlflow_kek.id
  secret_data = random_password.mlflow_kek.result
}

resource "google_secret_manager_secret_iam_member" "kek_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.mlflow_kek.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = module.service_account.member

  depends_on = [module.service_account]
}

module "gcs" {
  source = "./modules/gcs"

  project_id = var.project_id
  prefix     = var.prefix
  location   = var.gcs_location
  labels     = local.common_labels

  depends_on = [google_project_service.apis]
}

module "cloud_sql" {
  source = "./modules/cloud_sql"

  project_id    = var.project_id
  prefix        = var.prefix
  instance_name = var.cloudsql_instance_name
  database_name = var.mlflow_db_name
  db_user       = var.mlflow_db_user
  labels        = local.common_labels

  depends_on = [google_project_service.apis]
}

module "service_account" {
  source = "./modules/service_account"

  project_id               = var.project_id
  prefix                   = var.prefix
  db_password_secret_id    = module.cloud_sql.db_password_secret_id
  admin_password_secret_id = google_secret_manager_secret.mlflow_admin_password.secret_id

  depends_on = [module.cloud_sql]
}

resource "google_storage_bucket_iam_member" "mlflow_artifact_admin" {
  bucket = module.gcs.bucket_name
  role   = "roles/storage.objectAdmin"
  member = module.service_account.member
}

resource "google_storage_bucket_iam_member" "mlflow_legacy_bucket_reader" {
  bucket = module.gcs.bucket_name
  role   = "roles/storage.legacyBucketReader"
  member = module.service_account.member
}

resource "google_secret_manager_secret_iam_member" "demo_password_access" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.mlflow_demo_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = module.service_account.member
}
module "cloud_run" {
  source = "./modules/cloud_run"

  project_id               = var.project_id
  prefix                   = var.prefix
  region                   = var.cloud_run_region
  image                    = var.mlflow_image
  service_account_email    = module.service_account.email
  cloudsql_connection_name = module.cloud_sql.connection_name
  db_user                  = var.mlflow_db_user
  db_name                  = var.mlflow_db_name
  db_password_secret_id    = module.cloud_sql.db_password_secret_id
  admin_password_secret_id = google_secret_manager_secret.mlflow_admin_password.secret_id
  demo_password_secret_id  = google_secret_manager_secret.mlflow_demo_password.secret_id
  mlflow_admin_username    = var.mlflow_admin_username
  mlflow_demo_username     = var.mlflow_demo_username
  artifact_bucket_name     = module.gcs.bucket_name
  kek_passphrase_secret_id = google_secret_manager_secret.mlflow_kek.secret_id
  min_instances            = var.cloud_run_min_instances
  max_instances            = var.cloud_run_max_instances
  cpu                      = var.cloud_run_cpu
  memory                   = var.cloud_run_memory

  depends_on = [module.service_account, module.cloud_sql, module.gcs]
}
