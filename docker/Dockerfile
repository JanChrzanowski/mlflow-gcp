# ──────────────────────────────────────────────────────────────────────────────
# MLflow Tracking Server — production image for Google Cloud Run
#
# Build:
#   docker build -t mlflow:2.16.0 ./docker
#
# Push to Artifact Registry:
#   docker tag mlflow:2.16.0 europe-docker.pkg.dev/PROJECT/REPO/mlflow:2.16.0
#   docker push europe-docker.pkg.dev/PROJECT/REPO/mlflow:2.16.0
# ──────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS base

# System dependencies for psycopg2 and GCS client
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq5 \
        curl \
    && rm -rf /var/lib/apt/lists/*

# ── Builder stage — install Python packages ────────────────────────────────────
FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM base

LABEL maintainer="your-team@example.com" \
      org.opencontainers.image.title="MLflow Tracking Server" \
      org.opencontainers.image.description="MLflow on Cloud Run with Cloud SQL + GCS"

RUN groupadd --gid 1001 mlflow && \
    useradd  --uid 1001 --gid mlflow --shell /bin/bash --create-home mlflow

COPY --from=builder /install /usr/local

WORKDIR /app

COPY --chown=mlflow:mlflow entrypoint.sh /app/entrypoint.sh
COPY --chown=mlflow:mlflow basic_auth.ini /app/basic_auth.ini

RUN chmod +x /app/entrypoint.sh

EXPOSE 8080

USER mlflow

ENTRYPOINT ["/app/entrypoint.sh"]
