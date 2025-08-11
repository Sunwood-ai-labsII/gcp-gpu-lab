# RunPod VM モジュールのローカル変数

locals {
  # 共通タグ
  common_tags = concat([
    "runpod-vm",
    "ssh-access",
    "terraform-managed",
    var.environment
  ], var.additional_tags)
  
  # VM名
  vm_name = "${var.project_id}-${var.environment}-runpod-vm"
  
  # ネットワーク名
  network_name = "${var.project_id}-${var.environment}-vpc"
  subnet_name  = "${var.project_id}-${var.environment}-subnet"
  
  # SSH鍵の設定
  ssh_key_metadata = var.use_generated_ssh_key ? "${var.ssh_username}:${tls_private_key.ssh_key[0].public_key_openssh}" : "${var.ssh_username}:${file(var.ssh_public_key_path)}"
}