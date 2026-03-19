#!/bin/bash
# Синхронизация серверных файлов на VPS

VPS_USER="user"
VPS_HOST="YOUR_VPS_IP"
VPS_PATH="/home/$VPS_USER/mmorpg-server"
WATCH_DIRS="nakama-server nakama infrastructure modules docker-compose.yml server.yml"

echo "🔄 Syncing to $VPS_HOST..."

rsync -avz --delete \
  --exclude '.git' \
  --exclude '.env' \
  --exclude 'node_modules' \
  --exclude 'data/' \
  --exclude 'logs/' \
  --exclude 'certs/' \
  $WATCH_DIRS "$VPS_USER@$VPS_HOST:$VPS_PATH/"

echo "✅ Done. Restarting containers..."
ssh "$VPS_USER@$VPS_HOST" "cd $VPS_PATH && docker compose -f infrastructure/docker-compose.local.yml restart"