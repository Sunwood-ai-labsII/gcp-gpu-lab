# RunPod VM モジュール

# SSH鍵ペア生成（オプション）
resource "tls_private_key" "ssh_key" {
  count = var.use_generated_ssh_key ? 1 : 0
  
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 生成されたSSH鍵をローカルに保存
resource "local_file" "private_key" {
  count = var.use_generated_ssh_key ? 1 : 0
  
  content         = tls_private_key.ssh_key[0].private_key_pem
  filename        = "${path.root}/ssh-keys/${local.vm_name}-key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  count = var.use_generated_ssh_key ? 1 : 0
  
  content         = tls_private_key.ssh_key[0].public_key_openssh
  filename        = "${path.root}/ssh-keys/${local.vm_name}-key.pub"
  file_permission = "0644"
}

# Compute Engine インスタンス
resource "google_compute_instance" "runpod_vm" {
  name         = local.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  # スポットインスタンス設定
  scheduling {
    preemptible                 = true
    automatic_restart           = false
    on_host_maintenance        = "TERMINATE"
    provisioning_model         = "SPOT"
    instance_termination_action = "STOP"
  }

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-standard"
    }
    
    auto_delete = true
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.subnet.name
    
    access_config {
      # エフェメラル外部IPを割り当て
    }
  }

  # SSH公開鍵を設定
  metadata = {
    ssh-keys = local.ssh_key_metadata
  }

  # 起動スクリプト
  metadata_startup_script = file("${path.module}/startup-script.sh")

  # ラベル
  labels = {
    environment = var.environment
    managed-by  = "terraform"
    project     = var.project_id
  }

  tags = local.common_tags

  # 依存関係を明示
  depends_on = [
    google_compute_network.vpc_network,
    google_compute_subnetwork.subnet,
    google_compute_firewall.ssh,
  ]
}