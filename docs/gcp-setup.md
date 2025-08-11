# GCPセットアップガイド

GCPを初めて使う方向けの詳細なセットアップガイドです。

## 1. GCPアカウントの作成

### 1.1 Googleアカウントでサインアップ
1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. Googleアカウントでログイン（持っていない場合は作成）
3. 利用規約に同意

### 1.2 無料クレジット取得
- 初回登録で$300の無料クレジットがもらえます
- クレジットカード登録が必要ですが、無料期間中は課金されません

## 2. GCPプロジェクトの作成

### 2.1 新しいプロジェクトを作成
1. Google Cloud Consoleの上部にある「プロジェクトを選択」をクリック
2. 「新しいプロジェクト」をクリック
3. プロジェクト情報を入力：
   - **プロジェクト名**: 任意の名前（例：`My RunPod Project`）
   - **プロジェクトID**: 自動生成されるか手動で設定
   - **組織**: 個人利用なら「組織なし」

### 2.2 プロジェクトIDの確認
- プロジェクトIDは**グローバルで一意**である必要があります
- 例：`my-runpod-project-123456`
- このIDが`terraform.tfvars`で使用する`YOUR_PROJECT_ID`です

### 2.3 プロジェクトIDの見つけ方
1. Google Cloud Consoleの上部でプロジェクト名をクリック
2. 表示されるダイアログでプロジェクトIDを確認
3. または、ダッシュボードの「プロジェクト情報」カードで確認

## 3. 必要なAPIの有効化

### 3.1 Compute Engine APIの有効化
1. Google Cloud Consoleで「APIとサービス」→「ライブラリ」
2. 「Compute Engine API」を検索
3. 「有効にする」をクリック

### 3.2 その他の推奨API
- **Cloud Resource Manager API**: プロジェクト管理用
- **Cloud Billing API**: 課金情報取得用

## 4. 課金アカウントの設定

### 4.1 課金アカウントの作成
1. 「お支払い」メニューから課金アカウントを作成
2. クレジットカード情報を登録
3. プロジェクトと課金アカウントをリンク

### 4.2 予算アラートの設定（推奨）
1. 「お支払い」→「予算とアラート」
2. 「予算を作成」をクリック
3. 月額予算を設定（例：$10）
4. アラート閾値を設定（例：50%, 90%, 100%）

## 5. サービスアカウントの作成（オプション）

### 5.1 サービスアカウント作成
1. 「IAMと管理」→「サービスアカウント」
2. 「サービスアカウントを作成」
3. 名前とIDを設定（例：`terraform-runner`）

### 5.2 権限の付与
以下のロールを付与：
- **Compute Admin**: VM管理用
- **Security Admin**: ファイアウォール管理用
- **Service Account User**: サービスアカウント使用用

### 5.3 鍵ファイルのダウンロード
1. 作成したサービスアカウントをクリック
2. 「鍵」タブ→「鍵を追加」→「新しい鍵を作成」
3. JSON形式でダウンロード
4. ファイルを安全な場所に保存

## 6. gcloud CLIの設定

### 6.1 認証
```bash
# ブラウザ認証
gcloud auth login

# サービスアカウント認証（オプション）
gcloud auth activate-service-account --key-file=path/to/service-account.json
```

### 6.2 プロジェクト設定
```bash
# プロジェクトIDを設定
gcloud config set project YOUR_PROJECT_ID

# 現在の設定確認
gcloud config list
```

### 6.3 デフォルトリージョン設定
```bash
# リージョン設定（料金を抑えるため）
gcloud config set compute/region asia-northeast1
gcloud config set compute/zone asia-northeast1-a
```

## 7. 料金を抑えるコツ

### 7.1 リージョン選択
- **asia-northeast1** (東京): 日本から近いが少し高め
- **us-central1** (アイオワ): 最安だが遅延あり
- **asia-southeast1** (シンガポール): バランス型

### 7.2 マシンタイプ選択
- **e2-micro**: 最安（月約$5）、軽作業向け
- **e2-small**: 中程度（月約$10）、開発作業向け
- **e2-medium**: 高性能（月約$20）、重い作業向け

### 7.3 スポットインスタンス
- 通常価格の最大90%オフ
- 予告なく停止される可能性あり
- 開発・テスト環境に最適

## 8. セキュリティのベストプラクティス

### 8.1 SSH鍵管理
- 強力なパスフレーズを設定
- 定期的な鍵のローテーション
- 不要な鍵の削除

### 8.2 ファイアウォール
- 必要最小限のポートのみ開放
- 可能な限りIP制限を設定
- 定期的なルール見直し

### 8.3 監視とログ
- Cloud Loggingでログ監視
- Cloud Monitoringでリソース監視
- 異常なアクティビティのアラート設定

## トラブルシューティング

### よくあるエラー

#### 「プロジェクトが見つかりません」
- プロジェクトIDが正しいか確認
- プロジェクトが有効化されているか確認

#### 「APIが有効化されていません」
- Compute Engine APIが有効か確認
- 課金が有効化されているか確認

#### 「権限が不足しています」
- サービスアカウントの権限確認
- IAMロールの設定確認

### サポートリソース
- [Google Cloud ドキュメント](https://cloud.google.com/docs)
- [Google Cloud コミュニティ](https://cloud.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/google-cloud-platform)