###############################################################################
# Remote State — GCS backend
#
# Before first `terraform init`, create the bucket manually:
#   gsutil mb -p PROJECT_ID -l REGION gs://BUCKET_NAME
#   gsutil versioning set on gs://BUCKET_NAME
#
# Then replace the placeholder values below and run:
#   terraform init
###############################################################################

terraform {
  backend "gcs" {
    bucket = "tf-state-mlflow-my-portfolio-491517"   # replace before init
    prefix = "mlflow/terraform.tfstate"
  }
}
