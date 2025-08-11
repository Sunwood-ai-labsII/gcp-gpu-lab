# Terraform基礎ガイド

Terraformを初めて使う方向けの基礎ガイドです。

## Terraformとは？

**Terraform**は、インフラをコードで管理するツール（Infrastructure as Code）です。
設定ファイルに書いた内容通りにクラウドリソースを作成・管理できます。

### メリット
- **再現性**: 同じ環境を何度でも作成可能
- **バージョン管理**: インフラの変更履歴を管理
- **自動化**: 手動作業によるミスを削減
- **コスト管理**: 不要なリソースを確実に削除

## インストール

### Windows
```powershell
# Chocolateyを使用
choco install terraform

# または手動インストール
# https://www.terraform.io/downloads.html からダウンロード
```

### macOS
```bash
# Homebrewを使用
brew install terraform
```

### Linux
```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### インストール確認
```bash
terraform version
```

## 基本的な使い方

### 1. 初期化
```bash
terraform init
```
- プロバイダー（GCP、AWS等）をダウンロード
- 作業ディレクトリを初期化

### 2. プラン確認
```bash
terraform plan
```
- 実際に作成されるリソースを確認
- 変更内容をプレビュー

### 3. 適用
```bash
terraform apply
```
- リソースを実際に作成
- 確認プロンプトで`yes`を入力

### 4. 削除
```bash
terraform destroy
```
- 作成したリソースをすべて削除
- 確認プロンプトで`yes`を入力

## ファイル構成

### 基本的なファイル
- **main.tf**: メインの設定ファイル
- **variables.tf**: 変数定義
- **outputs.tf**: 出力値定義
- **terraform.tfvars**: 変数の値を設定

### 状態管理ファイル
- **terraform.tfstate**: 現在の状態を記録
- **.terraform/**: プロバイダーやモジュールを保存

## 変数の使い方

### variables.tfで定義
```hcl
variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "machine_type" {
  description = "VMのマシンタイプ"
  type        = string
  default     = "e2-micro"
}
```

### terraform.tfvarsで値を設定
```hcl
project_id = "my-gcp-project-123456"
machine_type = "e2-small"
```

### 使用方法
```hcl
resource "google_compute_instance" "vm" {
  name         = "my-vm"
  machine_type = var.machine_type
  project      = var.project_id
}
```

## 出力値の使い方

### outputs.tfで定義
```hcl
output "vm_ip" {
  description = "VMのIPアドレス"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
```

### 確認方法
```bash
# すべての出力値を表示
terraform output

# 特定の出力値を表示
terraform output vm_ip

# 値のみを表示（スクリプト用）
terraform output -raw vm_ip
```

## よく使うコマンド

### 状態確認
```bash
# 現在の状態を表示
terraform show

# リソース一覧を表示
terraform state list

# 特定のリソースの詳細を表示
terraform state show google_compute_instance.vm
```

### フォーマット
```bash
# コードを自動整形
terraform fmt

# 設定ファイルの検証
terraform validate
```

### インポート
```bash
# 既存のリソースをTerraformで管理
terraform import google_compute_instance.vm projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME
```

## ベストプラクティス

### 1. ファイル分割
```
project/
├── main.tf          # メインリソース
├── variables.tf     # 変数定義
├── outputs.tf       # 出力定義
├── network.tf       # ネットワーク関連
├── security.tf      # セキュリティ関連
└── terraform.tfvars # 変数値
```

### 2. 命名規則
- リソース名は小文字とハイフンを使用
- 変数名は小文字とアンダースコアを使用
- 説明的な名前を使用

### 3. バージョン管理
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
```

### 4. 状態ファイルの管理
```hcl
# リモートバックエンドの使用（本番環境）
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}
```

## トラブルシューティング

### よくあるエラー

#### 「terraform: command not found」
- Terraformがインストールされていない
- PATHが通っていない

#### 「Error: Invalid provider configuration」
- プロバイダーの設定が間違っている
- 認証情報が設定されていない

#### 「Error: Resource already exists」
- 同名のリソースが既に存在
- `terraform import`で既存リソースを取り込む

#### 「Error: Insufficient permissions」
- 権限が不足している
- サービスアカウントの権限を確認

### デバッグ方法
```bash
# 詳細ログを出力
export TF_LOG=DEBUG
terraform apply

# ログをファイルに保存
export TF_LOG_PATH=terraform.log
terraform apply
```

### 状態ファイルの修復
```bash
# 状態を最新に同期
terraform refresh

# 状態ファイルを再作成
terraform init -reconfigure
```

## 参考リソース

- [Terraform公式ドキュメント](https://www.terraform.io/docs)
- [Google Cloud Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)