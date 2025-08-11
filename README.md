# GCP GPU 開発環境

TerraformでGCPに安価なスポットインスタンスを構築してSSH接続するためのプロジェクトです。

## 特徴

- **モジュール化**: 再利用可能なTerraformモジュール
- **環境分離**: dev/prod環境の分離管理
- **スポットインスタンス**: 通常価格の最大90%オフ
- **最小構成**: e2-microで月約$3-4程度
- **自動セットアップ**: Docker、Python、Node.jsを自動インストール
- **SSH接続**: 公開鍵認証で安全に接続

## プロジェクト構成

```
.
├── environments/                    # 環境別設定
│   ├── dev/                        # 開発環境
│   │   ├── main.tf                 # 環境固有の設定
│   │   ├── variables.tf            # 変数定義
│   │   ├── outputs.tf              # 出力値
│   │   ├── versions.tf             # プロバイダー設定
│   │   ├── terraform.tfvars.example # 設定例（既存SSH鍵）
│   │   └── terraform-auto-keys.tfvars.example # 設定例（自動生成鍵）
│   └── prod/                       # 本番環境
│       ├── main.tf                 # 本番環境設定
│       ├── variables.tf            # 変数定義
│       ├── outputs.tf              # 出力値
│       ├── versions.tf             # プロバイダー設定（リモートバックエンド）
│       └── terraform.tfvars.example # 本番環境設定例
├── modules/                        # 再利用可能なモジュール
│   └── runpod-vm/                  # RunPod VMモジュール
│       ├── main.tf                 # VMリソース定義
│       ├── variables.tf            # モジュール変数
│       ├── outputs.tf              # モジュール出力
│       ├── locals.tf               # ローカル変数
│       ├── network.tf              # ネットワーク設定
│       ├── versions.tf             # プロバイダー制約
│       └── startup-script.sh       # VM起動スクリプト
├── docs/                           # ドキュメント
│   ├── gcp-setup.md               # GCP初期設定ガイド
│   ├── terraform-basics.md        # Terraform基礎
│   ├── ssh-guide.md               # SSH接続ガイド
│   └── cost-optimization.md       # 料金最適化
├── .gitignore                      # Git除外設定
└── README.md                       # このファイル
```

## 前提条件

- GCPアカウントとプロジェクト
- [Terraform](https://www.terraform.io/downloads.html) インストール済み
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) インストール済み

## クイックスタート

### 1. リポジトリのクローン

```bash
git clone <this-repository>
cd gcp-runpod-terraform
```

### 2. 認証とプロジェクト設定

**初めてGCPを使う方は [GCPセットアップガイド](docs/gcp-setup.md) を先に読んでください。**

```bash
# GCP認証
gcloud auth login
gcloud auth application-default login

# プロジェクト設定（gcp-runpod-gpu-labを実際のプロジェクトIDに置き換え）
gcloud config set project gcp-runpod-gpu-lab
```

**プロジェクトIDの確認方法**: Google Cloud Consoleの上部でプロジェクト名をクリックすると表示されます。

### 3. SSH鍵の準備（2つの方法から選択）

#### 方法A: 既存のSSH鍵を使用（推奨）
```bash
# SSH鍵生成（未作成の場合）
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

#### 方法B: GCP側で鍵を自動生成（AWS風）
SSH鍵をTerraformが自動生成します。手動での鍵作成は不要です。

### 4. 環境選択と設定

#### 開発環境（推奨）

```bash
# 開発環境ディレクトリに移動
cd environments/dev
```

#### 方法A: 既存SSH鍵を使用する場合
```bash
# 設定ファイルをコピー
cp terraform.tfvars.example terraform.tfvars

# プロジェクトIDを編集
vim terraform.tfvars
```

`terraform.tfvars`の内容例：
```hcl
project_id = "gcp-runpod-gpu-lab"
region = "asia-northeast1"
zone = "asia-northeast1-a"
machine_type = "e2-micro"
disk_size = 10
ssh_username = "ubuntu"
ssh_public_key_path = "~/.ssh/id_rsa.pub"
use_generated_ssh_key = false
enable_monitoring = false
```

#### 方法B: SSH鍵を自動生成する場合
```bash
# 自動生成用の設定ファイルをコピー
cp terraform-auto-keys.tfvars.example terraform.tfvars

# プロジェクトIDを編集
vim terraform.tfvars
```

### 5. デプロイ

```bash
# 開発環境ディレクトリで実行（既に移動済みの場合は不要）
cd environments/dev

# Terraformの初期化
terraform init

# デプロイプランの確認
terraform plan

# リソースの作成
terraform apply
```

デプロイには数分かかります。完了すると、VMの外部IPアドレスとSSH接続コマンドが表示されます。

### 6. SSH接続

```bash
# 開発環境ディレクトリで実行
cd environments/dev

# 接続コマンドを確認
terraform output ssh_command

# 接続実行（出力されたコマンドをコピペ）
# 方法Aの場合
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw vm_external_ip)

# 方法Bの場合（自動生成鍵）
ssh -i ../../ssh-keys/gcp-runpod-gpu-lab-dev-runpod-vm-key ubuntu@$(terraform output -raw vm_external_ip)
```

**初回接続時**: ホスト鍵の確認が表示されたら `yes` を入力してください。

## 料金目安

- **e2-micro スポットインスタンス**: 約$1-2/月
- **10GB標準ディスク**: 約$0.4/月
- **外部IP**: 約$1.5/月
- **合計**: 約$3-4/月

## 管理コマンド

```bash
# 開発環境ディレクトリで実行
cd environments/dev

# VMの停止（VM名を確認してから実行）
terraform output vm_name
gcloud compute instances stop $(terraform output -raw vm_name) --zone=$(terraform output -raw zone)

# VMの開始
gcloud compute instances start $(terraform output -raw vm_name) --zone=$(terraform output -raw zone)

# リソースの削除
terraform destroy
```

## 本番環境

本番環境用の設定は `environments/prod/` にあります：

```bash
# 本番環境ディレクトリに移動
cd environments/prod

# 設定ファイルをコピー
cp terraform.tfvars.example terraform.tfvars

# 本番環境用の設定を編集
vim terraform.tfvars

# リモートバックエンド用のGCSバケットを作成（初回のみ）
gsutil mb gs://your-terraform-state-bucket

# versions.tfでバケット名を更新
vim versions.tf

# デプロイ
terraform init
terraform plan
terraform apply
```

**本番環境の特徴：**
- より高性能なVM（e2-small、デフォルト）
- 大きなディスク（20GB、デフォルト）
- 監視機能が有効（デフォルト）
- リモートバックエンド設定済み（GCS）
- 本番用のタグ付け

## 設定項目

### 環境別設定（environments/*/terraform.tfvars）

| 項目                    | 説明                         | dev環境デフォルト     | prod環境デフォルト    | 例                     |
| ----------------------- | ---------------------------- | --------------------- | --------------------- | ---------------------- |
| `project_id`            | GCPプロジェクトID（必須）    | -                     | -                     | `"gcp-runpod-gpu-lab"` |
| `region`                | GCPリージョン                | `"asia-northeast1"`   | `"asia-northeast1"`   | `"us-central1"`        |
| `zone`                  | GCPゾーン                    | `"asia-northeast1-a"` | `"asia-northeast1-a"` | `"us-central1-a"`      |
| `machine_type`          | VMのマシンタイプ             | `"e2-micro"`          | `"e2-small"`          | `"n1-standard-1"`      |
| `disk_size`             | ディスクサイズ（GB）         | `10`                  | `20`                  | `50`                   |
| `ssh_username`          | SSH接続用ユーザー名          | `"ubuntu"`            | `"ubuntu"`            | `"admin"`              |
| `ssh_public_key_path`   | SSH公開鍵のパス（方法Aのみ） | `"~/.ssh/id_rsa.pub"` | `"~/.ssh/id_rsa.pub"` | `"./keys/my-key.pub"`  |
| `use_generated_ssh_key` | SSH鍵を自動生成するか        | `false`               | `false`               | `true`                 |
| `enable_monitoring`     | Cloud Monitoring有効化       | `false`               | `true`                | `true`                 |

### モジュール内部で自動設定される項目

| 項目           | 説明         | 設定値                                 |
| -------------- | ------------ | -------------------------------------- |
| `environment`  | 環境名       | 環境ディレクトリ名から自動設定         |
| `vm_name`      | VM名         | `{project_id}-{environment}-runpod-vm` |
| `network_name` | VPC名        | `{project_id}-{environment}-vpc`       |
| `subnet_name`  | サブネット名 | `{project_id}-{environment}-subnet`    |

## カスタマイズ

### VM設定の変更
```bash
# 環境ディレクトリで terraform.tfvars を編集
cd environments/dev
vim terraform.tfvars

# より高性能なVMに変更
machine_type = "e2-small"
disk_size = 20
```

### 起動スクリプトの編集
```bash
# 追加ソフトウェアのインストール
vim modules/runpod-vm/startup-script.sh

# 変更後は再デプロイが必要
cd environments/dev
terraform apply
```

### ファイアウォール設定の変更
```bash
# ポート設定を変更
vim modules/runpod-vm/network.tf

# 例：Jupyter Notebook用ポート8888を追加
# ports = ["80", "443", "8080", "3000", "8000", "8888"]
```

### 新しい環境の作成
```bash
# staging環境を作成
cp -r environments/dev environments/staging

# staging環境用の設定に変更
cd environments/staging
vim main.tf  # environment = "staging" に変更
vim terraform.tfvars  # 必要に応じて設定を調整
```

## SSH鍵管理の違い

| 項目     | 方法A（手動鍵）    | 方法B（GCP自動生成） |
| -------- | ------------------ | -------------------- |
| 鍵の管理 | ローカルで管理     | Terraformが管理      |
| 鍵の場所 | `~/.ssh/`          | `./ssh-keys/`        |
| 利点     | 既存鍵を再利用可能 | AWS風の自動管理      |
| 欠点     | 事前準備が必要     | Terraformに依存      |

## 詳細ガイド

- **[GCPセットアップガイド](docs/gcp-setup.md)**: GCPアカウント作成からプロジェクト設定まで
- **[Terraform基礎ガイド](docs/terraform-basics.md)**: Terraformの基本的な使い方
- **[SSH接続ガイド](docs/ssh-guide.md)**: SSH鍵の作成から接続まで
- **[料金最適化ガイド](docs/cost-optimization.md)**: 料金を抑えるテクニック

## モジュールの再利用

他のプロジェクトでRunPod VMモジュールを再利用する場合：

```hcl
# 他のプロジェクトのmain.tf
module "my_runpod" {
  source = "git::https://github.com/your-repo/gcp-runpod-terraform.git//modules/runpod-vm"
  
  # 必須パラメータ
  project_id = "my-other-project"
  region     = "us-central1"
  zone       = "us-central1-a"
  environment = "staging"
  
  # VM設定
  machine_type = "e2-small"
  disk_size    = 15
  
  # SSH設定
  ssh_username = "admin"
  use_generated_ssh_key = true
  
  # オプション
  enable_monitoring = true
  additional_tags   = ["custom-tag", "team-alpha"]
}

# 出力値の使用
output "vm_ip" {
  value = module.my_runpod.vm_external_ip
}

output "ssh_command" {
  value = module.my_runpod.ssh_command
}
```

## トラブルシューティング

### よくある問題

#### 「terraform: command not found」
```bash
# Terraformがインストールされていない
# https://www.terraform.io/downloads.html からインストール
```

#### 「Error: Invalid provider configuration」
```bash
# GCP認証が設定されていない
gcloud auth application-default login
```

#### 「Error: googleapi: Error 403: Compute Engine API has not been used」
```bash
# Compute Engine APIが有効化されていない
gcloud services enable compute.googleapis.com
```

#### SSH接続できない
```bash
# VMの起動完了を待つ
sleep 60

# ファイアウォールルールを確認
gcloud compute firewall-rules list --filter="name:*allow-ssh*"

# VM状態を確認
terraform output vm_name
gcloud compute instances describe $(terraform output -raw vm_name) --zone=$(terraform output -raw zone)
```

### ログの確認
```bash
# Terraformのデバッグログ
export TF_LOG=DEBUG
terraform apply

# VM起動ログの確認（SSH接続後）
sudo tail -f /var/log/startup-script.log
```

## 注意事項

- **スポットインスタンス**: 予告なく停止される可能性があります
- **データバックアップ**: 重要なデータは定期的にバックアップしてください
- **セキュリティ**: 本番環境では適切なセキュリティ設定を行ってください
- **SSH鍵管理**: 自動生成する場合、`ssh-keys/`フォルダは`.gitignore`に追加済みです
- **料金管理**: 使用しない時はVMを停止して料金を節約してください
- **リソース削除**: 不要になったら`terraform destroy`でリソースを削除してください
