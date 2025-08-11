# 本番環境用のTerraformとプロバイダーのバージョン制約

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  # 本番環境ではリモートバックエンドを推奨
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "environments/prod/terraform.tfstate"
  }
}

# プロバイダー設定
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}