#!/usr/bin/env bash
set -euo pipefail

: "${DB_USER:?DB_USER is required}"
: "${DB_NAME:?DB_NAME is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${CLOUDSQL_CONNECTION_NAME:?CLOUDSQL_CONNECTION_NAME is required}"
: "${MLFLOW_ARTIFACT_ROOT:?MLFLOW_ARTIFACT_ROOT is required}"

HOST="${MLFLOW_HOST:-0.0.0.0}"
PORT="${MLFLOW_PORT:-8080}"
WORKERS="${MLFLOW_WORKERS:-2}"

export PGPASSWORD="${DB_PASSWORD}"
BACKEND_STORE_URI="postgresql+psycopg2://${DB_USER}@/${DB_NAME}?host=/cloudsql/${CLOUDSQL_CONNECTION_NAME}"

echo "[entrypoint] Starting MLflow (no auth)..."
echo "[entrypoint]   db        = ${DB_USER}@/${DB_NAME} via ${CLOUDSQL_CONNECTION_NAME}"
echo "[entrypoint]   artifacts = ${MLFLOW_ARTIFACT_ROOT}"

exec mlflow server \
  --host "${HOST}" \
  --port "${PORT}" \
  --backend-store-uri "${BACKEND_STORE_URI}" \
  --default-artifact-root "${MLFLOW_ARTIFACT_ROOT}"
