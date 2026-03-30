###############################################################################
# Module: cloud_run
# MLflow Tracking Server on Cloud Run.
#
# Security model (without a Load Balancer):
#   - Cloud Run endpoint is HTTPS-only (Google-managed TLS)
#   - allUsers invoker is granted so the URL is reachable
#   - MLflow built-in basic-auth (--app-name basic-auth) enforces credentials
#   - admin role  → MANAGE permission (set by entrypoint.sh via MLflow Auth API)
#   - demo_user   → EDIT  permission (run experiments, read artifacts)
#
# NOTE: When a Load Balancer + IAP is added later, remove the allUsers binding
#       and set ingress = INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER.
###############################################################################

locals {
  backend_store_uri = "postgresql+psycopg2://${var.db_user}@/${var.db_name}?host=/cloudsql/${var.cloudsql_connection_name}"
  artifact_root     = "gs://${var.artifact_bucket_name}/mlflow-artifacts"
}

resource "google_cloud_run_v2_service" "mlflow" {
  project  = var.project_id
  name     = "${var.prefix}-mlflow"
  location = var.region

  deletion_protection = false

  # All external HTTPS traffic is accepted; auth is handled by MLflow basic-auth
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.service_account_email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # ── Cloud SQL Unix socket ──────────────────────────────────────────────────
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloudsql_connection_name]
      }
    }

    containers {
      name  = "mlflow"
      image = var.image

      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      # ── Static env vars ────────────────────────────────────────────────────
      # URI zawiera placeholder DB_PASSWORD — entrypoint.sh podstawia go po
      # URL-encodowaniu hasła przez Pythona (bezpieczne dla znaków specjalnych)
      env {
        name  = "MLFLOW_BACKEND_STORE_URI"
        value = local.backend_store_uri
      }

      env {
        name  = "MLFLOW_ARTIFACT_ROOT"
        value = local.artifact_root
      }

      env {
        name  = "CLOUDSQL_CONNECTION_NAME"
        value = var.cloudsql_connection_name
      }

      env {
        name  = "MLFLOW_HOST"
        value = "0.0.0.0"
      }

      # MLflow 3.x TrustedHostMiddleware (wymaga uvicorn, nie Gunicorn)
      # Docelowo zastąp '*' konkretną domeną po zmapowaniu
      env {
        name  = "MLFLOW_SERVER_ALLOWED_HOSTS"
        value = "*"
      }

      env {
        name  = "MLFLOW_PORT"
        value = "8080"
      }

      env {
        name  = "DB_USER"
        value = var.db_user
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      env {
        name  = "MLFLOW_ADMIN_USERNAME"
        value = var.mlflow_admin_username
      }

      env {
        name  = "MLFLOW_DEMO_USERNAME"
        value = var.mlflow_demo_username
      }

      # ── Secrets from Secret Manager ────────────────────────────────────────
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.db_password_secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MLFLOW_ADMIN_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.admin_password_secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MLFLOW_DEMO_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.demo_password_secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "MLFLOW_CRYPTO_KEK_PASSPHRASE"
        value_source {
          secret_key_ref {
            secret  = var.kek_passphrase_secret_id
            version = "latest"
          }
        }
      }

      ports {
        name           = "http1"
        container_port = 8080
      }

      startup_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 15
        period_seconds        = 10
        failure_threshold     = 6
      }

      liveness_probe {
        http_get {
          path = "/health"
        }
        period_seconds    = 30
        failure_threshold = 3
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Allow CI/CD pipelines to push new images without Terraform conflicts
      template[0].containers[0].image,
    ]
  }
}

# ── Allow unauthenticated HTTP requests (MLflow basic-auth is the gate) ────────
resource "google_cloud_run_v2_service_iam_member" "public_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.mlflow.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
