# RunPod VM モジュールの変数定義

variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "region" {
  description = "GCPリージョン"
  type        = string
}

variable "zone" {
  description = "GCPゾーン"
  type        = string
}

variable "machine_type" {
  description = "VMのマシンタイプ"
  type        = string
}

variable "image" {
  description = "VMのOSイメージ"
  type        = string
}

variable "disk_size" {
  description = "ディスクサイズ（GB）"
  type        = number
}

variable "ssh_username" {
  description = "SSH接続用のユーザー名"
  type        = string
}

variable "ssh_public_key_path" {
  description = "SSH公開鍵のパス"
  type        = string
}

variable "use_generated_ssh_key" {
  description = "SSH鍵をTerraformで自動生成するか"
  type        = bool
}

variable "environment" {
  description = "環境名（dev, staging, prod等）"
  type        = string
}

variable "enable_monitoring" {
  description = "Cloud Monitoringを有効にするか"
  type        = bool
}

variable "additional_tags" {
  description = "追加のネットワークタグ"
  type        = list(string)
  default     = []
}