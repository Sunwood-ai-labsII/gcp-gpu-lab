#!/bin/bash

# システムアップデート
apt-get update
apt-get upgrade -y

# 基本的なツールをインストール
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    build-essential

# Docker インストール（オプション）
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Python3とpipをインストール
apt-get install -y python3 python3-pip

# Node.js インストール（オプション）
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# ログ出力
echo "Startup script completed at $(date)" >> /var/log/startup-script.log