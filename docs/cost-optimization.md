# GCP料金最適化ガイド

GCPでRunPod風の安価なVMを運用するための料金最適化テクニックを説明します。

## 料金の基本構造

### 主要な課金要素
1. **Compute Engine**: VM本体の料金
2. **Persistent Disk**: ストレージ料金
3. **Network**: 外部IP・データ転送料金
4. **その他**: ロードバランサー、DNS等

## スポットインスタンス（プリエンプティブル）

### 概要
- 通常価格の**最大90%オフ**
- Googleが必要に応じて停止する可能性あり
- 24時間以内に必ず停止される

### 適用場面
- **開発・テスト環境**: 本番以外の用途
- **バッチ処理**: 中断されても再開可能な処理
- **学習・実験**: 個人的な学習用途

### 設定方法
```hcl
resource "google_compute_instance" "vm" {
  scheduling {
    preemptible                 = true
    automatic_restart           = false
    on_host_maintenance        = "TERMINATE"
    provisioning_model         = "SPOT"
    instance_termination_action = "STOP"
  }
}
```

## マシンタイプの選択

### E2シリーズ（最安）
| タイプ | vCPU | メモリ | 月額（通常） | 月額（スポット） |
|--------|------|--------|-------------|----------------|
| e2-micro | 0.25-2 | 1GB | $5.11 | $1.53 |
| e2-small | 0.5-2 | 2GB | $10.22 | $3.07 |
| e2-medium | 1-2 | 4GB | $20.44 | $6.13 |

### N1シリーズ（GPU対応）
| タイプ | vCPU | メモリ | 月額（通常） | 月額（スポット） |
|--------|------|--------|-------------|----------------|
| n1-standard-1 | 1 | 3.75GB | $24.27 | $7.28 |
| n1-standard-2 | 2 | 7.5GB | $48.55 | $14.57 |

### 選択指針
- **軽作業**: e2-micro（最安）
- **開発作業**: e2-small
- **GPU必要**: n1-standard-1 + GPU

## リージョン・ゾーンの選択

### 料金比較（e2-micro/月）
| リージョン | 場所 | 通常価格 | スポット価格 | 遅延 |
|------------|------|----------|-------------|------|
| us-central1 | アイオワ | $5.11 | $1.53 | 高 |
| us-west1 | オレゴン | $5.11 | $1.53 | 高 |
| asia-southeast1 | シンガポール | $5.69 | $1.71 | 中 |
| asia-northeast1 | 東京 | $6.11 | $1.83 | 低 |

### 推奨選択
- **最安重視**: us-central1
- **バランス**: asia-southeast1
- **低遅延**: asia-northeast1

## ストレージの最適化

### ディスクタイプ比較
| タイプ | 用途 | 料金/GB/月 | IOPS |
|--------|------|-----------|------|
| pd-standard | 一般用途 | $0.040 | 低 |
| pd-balanced | バランス | $0.100 | 中 |
| pd-ssd | 高性能 | $0.170 | 高 |

### 最適化テクニック
```hcl
boot_disk {
  initialize_params {
    size = 10          # 最小サイズ
    type = "pd-standard"  # 最安タイプ
  }
}
```

### 不要なスナップショットの削除
```bash
# 古いスナップショットを削除
gcloud compute snapshots list --filter="creationTimestamp<'2024-01-01'"
gcloud compute snapshots delete SNAPSHOT_NAME
```

## ネットワーク料金の最適化

### 外部IP料金
- **静的IP**: $1.46/月（使用中）
- **エフェメラルIP**: $1.46/月（未使用時のみ）
- **内部IP**: 無料

### データ転送料金
- **同一ゾーン内**: 無料
- **同一リージョン内**: 無料
- **外部への送信**: $0.12/GB〜

### 最適化方法
```hcl
# エフェメラルIPを使用（使用中は無料）
network_interface {
  access_config {
    # 外部IPを割り当て（エフェメラル）
  }
}
```

## 自動化による料金削減

### 自動停止スクリプト
```bash
#!/bin/bash
# 夜間自動停止（crontabで設定）
# 0 22 * * * /path/to/stop-vm.sh

gcloud compute instances stop runpod-vm --zone=asia-northeast1-a
```

### 自動起動スクリプト
```bash
#!/bin/bash
# 朝の自動起動
# 0 9 * * 1-5 /path/to/start-vm.sh

gcloud compute instances start runpod-vm --zone=asia-northeast1-a
```

### Cloud Schedulerを使用
```bash
# 停止ジョブの作成
gcloud scheduler jobs create http stop-vm-job \
    --schedule="0 22 * * *" \
    --uri="https://compute.googleapis.com/compute/v1/projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME/stop" \
    --http-method=POST \
    --oauth-service-account-email=SERVICE_ACCOUNT_EMAIL
```

## 監視とアラート

### 予算アラートの設定
```bash
# 予算を作成
gcloud billing budgets create \
    --billing-account=BILLING_ACCOUNT_ID \
    --display-name="RunPod Budget" \
    --budget-amount=10USD \
    --threshold-rule=percent=0.5 \
    --threshold-rule=percent=0.9 \
    --threshold-rule=percent=1.0
```

### コスト分析
```bash
# 現在の使用量確認
gcloud billing accounts list
gcloud billing projects describe PROJECT_ID

# 詳細な課金情報をエクスポート
# BigQueryでの分析が可能
```

## 無料枠の活用

### Always Free枠
- **e2-micro**: 1インスタンス（米国リージョンのみ）
- **30GB HDD**: 標準永続ディスク
- **5GB スナップショット**: 月間
- **1GB 外部送信**: 月間（中国・オーストラリア除く）

### 条件
- 米国リージョン（us-west1, us-central1, us-east1）
- e2-microインスタンスのみ
- 1つのプロジェクトにつき1インスタンス

## 料金計算例

### 最安構成（スポット + 無料枠）
```
e2-micro (us-central1, スポット): $0/月（無料枠）
30GB pd-standard: $0/月（無料枠）
外部IP（使用中）: $0/月（無料枠適用外だが実質無料）
合計: 約$0-1/月
```

### 実用的構成（東京リージョン）
```
e2-small (asia-northeast1, スポット): $3.07/月
10GB pd-standard: $0.40/月
外部IP: $1.46/月
合計: 約$5/月
```

### 高性能構成
```
n1-standard-1 (asia-northeast1, スポット): $7.28/月
20GB pd-ssd: $3.40/月
外部IP: $1.46/月
合計: 約$12/月
```

## 料金最適化チェックリスト

### 設定時
- [ ] スポットインスタンスを有効化
- [ ] 最安リージョンを選択
- [ ] 必要最小限のマシンタイプを選択
- [ ] pd-standardディスクを使用
- [ ] 不要なファイアウォールルールを削除

### 運用時
- [ ] 使用しない時間帯は停止
- [ ] 不要なスナップショットを削除
- [ ] 予算アラートを設定
- [ ] 月次で料金レビュー
- [ ] 無料枠の活用状況を確認

### 監視項目
- [ ] 月間使用量の推移
- [ ] リソース使用率
- [ ] 予算に対する進捗
- [ ] 不要なリソースの特定

## トラブルシューティング

### 予想より高い料金
1. **課金レポートを確認**
   ```bash
   gcloud billing accounts list
   ```

2. **リソース使用量を確認**
   - Cloud Consoleの「課金」セクション
   - 詳細な内訳を分析

3. **不要なリソースを特定**
   ```bash
   # 全リソースを確認
   gcloud compute instances list
   gcloud compute disks list
   gcloud compute addresses list
   ```

### スポットインスタンスが頻繁に停止
- より安定したリージョンに移行
- 通常インスタンスへの変更を検討
- 自動再起動スクリプトの実装

## 参考リソース

- [GCP料金計算ツール](https://cloud.google.com/products/calculator)
- [GCP無料枠詳細](https://cloud.google.com/free)
- [Compute Engine料金](https://cloud.google.com/compute/pricing)
- [課金管理ベストプラクティス](https://cloud.google.com/billing/docs/how-to/budgets)