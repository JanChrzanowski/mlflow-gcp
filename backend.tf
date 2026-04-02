
terraform {
  backend "gcs" {
    bucket = "tf-state-mlflow-my-portfolio-491517"   # replace before init
    prefix = "mlflow/terraform.tfstate"
  }
}
