# 本番環境用のTerraform設定

module "runpod_vm" {
  source = "../../modules/runpod-vm"

  # プロジェクト設定
  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  # VM設定（本番環境用）
  machine_type = var.machine_type
  disk_size    = var.disk_size
  image        = var.image

  # SSH設定
  ssh_username          = var.ssh_username
  ssh_public_key_path   = var.ssh_public_key_path
  use_generated_ssh_key = var.use_generated_ssh_key

  # 環境設定
  environment       = "prod"
  enable_monitoring = var.enable_monitoring

  # タグ
  additional_tags = ["production", "persistent"]
}