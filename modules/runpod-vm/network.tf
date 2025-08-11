# RunPod VM モジュールのネットワーク設定

# VPCネットワーク
resource "google_compute_network" "vpc_network" {
  name                    = local.network_name
  auto_create_subnetworks = false
  description             = "VPC network for ${var.project_id} ${var.environment} RunPod environment"
  
  # ネットワークの削除保護
  delete_default_routes_on_create = false
}

# サブネット
resource "google_compute_subnetwork" "subnet" {
  name          = local.subnet_name
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  description   = "Subnet for ${var.project_id} ${var.environment} RunPod VMs"
  
  # プライベートGoogleアクセスを有効化
  private_ip_google_access = true
}

# ファイアウォールルール（SSH接続用）
resource "google_compute_firewall" "ssh" {
  name        = "${local.network_name}-allow-ssh"
  network     = google_compute_network.vpc_network.name
  description = "Allow SSH access to ${var.environment} RunPod VMs"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # 本番環境では特定のIPに制限することを推奨
  target_tags   = ["ssh-access"]
  
  priority = 1000
}

# ファイアウォールルール（HTTP/HTTPS用）
resource "google_compute_firewall" "web" {
  name        = "${local.network_name}-allow-web"
  network     = google_compute_network.vpc_network.name
  description = "Allow HTTP/HTTPS access to ${var.environment} RunPod VMs"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "3000", "8000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["runpod-vm"]
  
  priority = 1000
}

# ファイアウォールルール（内部通信用）
resource "google_compute_firewall" "internal" {
  name        = "${local.network_name}-allow-internal"
  network     = google_compute_network.vpc_network.name
  description = "Allow internal communication within ${var.environment} VPC"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
  
  priority = 1000
}