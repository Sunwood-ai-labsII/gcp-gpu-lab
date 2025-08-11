# SSH接続ガイド

SSH（Secure Shell）を使ってVMに安全に接続する方法を説明します。

## SSHとは？

**SSH**は、ネットワーク経由でリモートサーバーに安全に接続するためのプロトコルです。
暗号化された通信でサーバーを操作できます。

## SSH鍵の基礎知識

### 公開鍵暗号方式
- **秘密鍵**: 自分だけが持つ鍵（絶対に他人に渡さない）
- **公開鍵**: サーバーに登録する鍵（他人に見られても安全）

### 鍵ペアの生成
```bash
# RSA鍵（推奨）
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# ED25519鍵（より新しい方式）
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### 生成される鍵ファイル
- **id_rsa**: 秘密鍵（権限600で保護）
- **id_rsa.pub**: 公開鍵（サーバーに登録）

## Windows環境でのSSH

### Windows 10/11の場合
```powershell
# OpenSSHクライアントが標準搭載
ssh username@server-ip

# 鍵を指定して接続
ssh -i path\to\private-key username@server-ip
```

### PuTTYを使用する場合
1. [PuTTY](https://www.putty.org/)をダウンロード
2. PuTTYgenで鍵ペアを生成
3. PuTTYで接続設定を保存

## SSH接続の基本

### 基本的な接続
```bash
ssh username@server-ip
```

### 鍵ファイルを指定
```bash
ssh -i ~/.ssh/id_rsa username@server-ip
```

### ポートを指定
```bash
ssh -p 2222 username@server-ip
```

### 初回接続時の確認
```
The authenticity of host 'server-ip' can't be established.
ECDSA key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```
→ `yes`を入力してホスト鍵を保存

## SSH設定ファイル

### ~/.ssh/configの作成
```bash
# 設定ファイルを作成
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

### 設定例
```
# GCP RunPod VM
Host runpod
    HostName 35.200.123.456
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    Port 22

# 複数のサーバー設定
Host dev-server
    HostName dev.example.com
    User developer
    IdentityFile ~/.ssh/dev_key
```

### 設定ファイルを使った接続
```bash
# 設定名で接続
ssh runpod

# 長いコマンドが不要
ssh dev-server
```

## セキュリティのベストプラクティス

### 1. 強力なパスフレーズ
```bash
# 鍵生成時にパスフレーズを設定
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
Enter passphrase (empty for no passphrase): [強力なパスフレーズを入力]
```

### 2. 鍵ファイルの権限設定
```bash
# 秘密鍵の権限を制限
chmod 600 ~/.ssh/id_rsa

# 公開鍵の権限設定
chmod 644 ~/.ssh/id_rsa.pub

# .sshディレクトリの権限
chmod 700 ~/.ssh
```

### 3. SSH Agentの使用
```bash
# SSH Agentを起動
eval "$(ssh-agent -s)"

# 鍵をAgentに追加
ssh-add ~/.ssh/id_rsa

# 追加された鍵を確認
ssh-add -l
```

### 4. 不要な鍵の削除
```bash
# 古い鍵を削除
rm ~/.ssh/old_key ~/.ssh/old_key.pub

# サーバーからも公開鍵を削除
# ~/.ssh/authorized_keysから該当行を削除
```

## トラブルシューティング

### よくあるエラー

#### 「Permission denied (publickey)」
**原因**: 公開鍵がサーバーに登録されていない
**解決策**:
```bash
# 公開鍵をサーバーにコピー
ssh-copy-id -i ~/.ssh/id_rsa.pub username@server-ip

# 手動でコピー
cat ~/.ssh/id_rsa.pub | ssh username@server-ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

#### 「Host key verification failed」
**原因**: サーバーのホスト鍵が変更された
**解決策**:
```bash
# 古いホスト鍵を削除
ssh-keygen -R server-ip

# 再接続して新しいホスト鍵を受け入れ
ssh username@server-ip
```

#### 「Connection timed out」
**原因**: ファイアウォールでSSHポートがブロックされている
**解決策**:
- GCPのファイアウォールルールを確認
- ポート22が開放されているか確認

#### 「Bad permissions」
**原因**: 鍵ファイルの権限が適切でない
**解決策**:
```bash
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 700 ~/.ssh
```

### デバッグ方法
```bash
# 詳細ログを出力
ssh -v username@server-ip

# より詳細なログ
ssh -vvv username@server-ip
```

## ファイル転送

### SCPを使用
```bash
# ローカルからサーバーへ
scp file.txt username@server-ip:/remote/path/

# サーバーからローカルへ
scp username@server-ip:/remote/file.txt ./local/path/

# ディレクトリを再帰的にコピー
scp -r local-dir/ username@server-ip:/remote/path/
```

### RSYNCを使用
```bash
# より効率的な同期
rsync -avz local-dir/ username@server-ip:/remote/path/

# SSH鍵を指定
rsync -avz -e "ssh -i ~/.ssh/id_rsa" local-dir/ username@server-ip:/remote/path/
```

## SSH Tunneling

### ローカルポートフォワーディング
```bash
# リモートサーバーのポート8080をローカルの8080に転送
ssh -L 8080:localhost:8080 username@server-ip
```

### リモートポートフォワーディング
```bash
# ローカルのポート3000をリモートサーバーの3000に転送
ssh -R 3000:localhost:3000 username@server-ip
```

### 動的ポートフォワーディング（SOCKSプロキシ）
```bash
# ローカルの1080ポートをSOCKSプロキシとして使用
ssh -D 1080 username@server-ip
```

## 参考リソース

- [OpenSSH公式ドキュメント](https://www.openssh.com/manual.html)
- [SSH Academy](https://www.ssh.com/academy/ssh)
- [GitHub SSH設定ガイド](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)