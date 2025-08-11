# 本番環境用の変数定義

variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "region" {
  description = "GCPリージョン"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "GCPゾーン"
  type        = string
  default     = "asia-northeast1-a"
}

variable "machine_type" {
  description = "VMのマシンタイプ"
  type        = string
  default     = "e2-small"  # 本番環境はより高性能
}

variable "image" {
  description = "VMのOSイメージ"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "disk_size" {
  description = "ディスクサイズ（GB）"
  type        = number
  default     = 20  # 本番環境はより大きなディスク
}

variable "ssh_username" {
  description = "SSH接続用のユーザー名"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  description = "SSH公開鍵のパス"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "use_generated_ssh_key" {
  description = "SSH鍵をTerraformで自動生成するか"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Cloud Monitoringを有効にするか"
  type        = bool
  default     = true  # 本番環境は監視を有効化
}