# 開発環境用のTerraformとプロバイダーのバージョン制約

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# プロバイダー設定
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# リモートバックエンド設定（オプション）
# terraform {
#   backend "gcs" {
#     bucket = "your-terraform-state-bucket"
#     prefix = "environments/dev/terraform.tfstate"
#   }
# }