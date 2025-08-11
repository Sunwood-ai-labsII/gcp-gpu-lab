# 本番環境用の出力値

output "vm_external_ip" {
  description = "VMの外部IPアドレス"
  value       = module.runpod_vm.vm_external_ip
}

output "vm_internal_ip" {
  description = "VMの内部IPアドレス"
  value       = module.runpod_vm.vm_internal_ip
}

output "ssh_command" {
  description = "SSH接続コマンド"
  value       = module.runpod_vm.ssh_command
}

output "ssh_key_path" {
  description = "SSH秘密鍵のパス"
  value       = module.runpod_vm.ssh_key_path
}

output "vm_name" {
  description = "VM名"
  value       = module.runpod_vm.vm_name
}

output "network_name" {
  description = "VPCネットワーク名"
  value       = module.runpod_vm.network_name
}

output "instance_id" {
  description = "インスタンスID"
  value       = module.runpod_vm.instance_id
}