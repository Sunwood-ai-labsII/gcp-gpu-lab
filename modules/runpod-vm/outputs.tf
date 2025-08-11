# RunPod VM モジュールの出力値

output "vm_external_ip" {
  description = "VMの外部IPアドレス"
  value       = google_compute_instance.runpod_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_internal_ip" {
  description = "VMの内部IPアドレス"
  value       = google_compute_instance.runpod_vm.network_interface[0].network_ip
}

output "ssh_command" {
  description = "SSH接続コマンド"
  value = var.use_generated_ssh_key ? (
    "ssh -i ./ssh-keys/${local.vm_name}-key ${var.ssh_username}@${google_compute_instance.runpod_vm.network_interface[0].access_config[0].nat_ip}"
  ) : (
    "ssh -i ~/.ssh/id_rsa ${var.ssh_username}@${google_compute_instance.runpod_vm.network_interface[0].access_config[0].nat_ip}"
  )
}

output "ssh_key_path" {
  description = "SSH秘密鍵のパス"
  value = var.use_generated_ssh_key ? (
    length(local_file.private_key) > 0 ? local_file.private_key[0].filename : null
  ) : "~/.ssh/id_rsa"
}

output "vm_name" {
  description = "VM名"
  value       = google_compute_instance.runpod_vm.name
}

output "zone" {
  description = "VMのゾーン"
  value       = google_compute_instance.runpod_vm.zone
}

output "network_name" {
  description = "VPCネットワーク名"
  value       = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "サブネット名"
  value       = google_compute_subnetwork.subnet.name
}

output "instance_id" {
  description = "インスタンスID"
  value       = google_compute_instance.runpod_vm.instance_id
}