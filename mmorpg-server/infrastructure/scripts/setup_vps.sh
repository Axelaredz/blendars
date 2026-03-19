#!/bin/bash
# VPS Setup Script for Blendars Game Server
# Ubuntu 24.04

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Blendars VPS Setup Script ===${NC}"
echo -e "${GREEN}Starting VPS configuration...${NC}"

# Проверка что скрипт запущен от root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Обновление системы
echo -e "${YELLOW}Updating system packages...${NC}"
apt update && apt upgrade -y

# Установка базовых пакетов
echo -e "${YELLOW}Installing base packages...${NC}"
apt install -y curl wget git htop net-tools ufw fail2ban software-properties-common

# Установка Docker
echo -e "${YELLOW}Installing Docker...${NC}"

# Удаление старых версий Docker
apt remove -y docker.io docker-compose docker-compose-v2 || true

# Установка Docker через официальный скрипт
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sh /tmp/get-docker.sh

# Установка Docker Compose plugin
apt install -y docker-compose-plugin

# Включение и запуск Docker
systemctl enable docker
systemctl start docker

# Добавление текущего пользователя в группу docker
usermod -aG docker $SUDO_USER

# Настройка Firewall
echo -e "${YELLOW}Configuring firewall (UFW)...${NC}"

# Политика по умолчанию
ufw default deny incoming
ufw default allow outgoing

# Открытие портов
ufw allow 22/tcp    # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw allow 7350/tcp # Nakama HTTP
ufw allow 7351/tcp # Nakama Metrics
ufw allow 7777/tcp # Game Server
ufw allow 7778/udp # Game Server (ENet)

# Включение firewall
echo "y" | ufw enable

# Настройка SSH
echo -e "${YELLOW}Configuring SSH...${NC}"

# Бэкап оригинального конфига SSH
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Настройка sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Перезапуск SSH
systemctl reload sshd

# Настройка Swap (если нужно)
echo -e "${YELLOW}Configuring swap...${NC}"
if [ -f /swapfile ]; then
    echo "Swap already exists"
else
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Настройка sysctl для сетевой оптимизации
echo -e "${YELLOW}Configuring network settings...${NC}"

cat >> /etc/sysctl.conf <<EOF
# Network optimization for game server
net.core.somaxconn = 1024
net.core.netdev_max_backlog = 65536
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10000 65535
EOF

sysctl -p

# Создание директории для проекта
echo -e "${YELLOW}Creating project directory...${NC}"
mkdir -p /opt/blendars
mkdir -p /opt/blendars/{config,data,logs}
mkdir -p /var/log/blendars

# Создание пользователя для game server (опционально)
# echo -e "${YELLOW}Creating dedicated user...${NC}"
# useradd -r -s /bin/false blendars || true
# chown -R blendars:blendars /opt/blendars

# Настройка logrotate для логов
echo -e "${YELLOW}Configuring logrotate...${NC}"

cat > /etc/logrotate.d/blendars <<EOF
/var/log/blendars/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
EOF

# Настройка fail2ban
echo -e "${YELLOW}Configuring fail2ban...${NC}"

cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# Установка Node.js (для Nakama модулей)
echo -e "${YELLOW}Installing Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Установка Docker Compose (standalone, если нужно)
# apt install -y docker-compose

# Финальное сообщение
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo -e "${GREEN}VPS is ready. Next steps:${NC}"
echo "1. Copy your SSH public key to ~/.ssh/authorized_keys"
echo "2. Upload infrastructure/ to /opt/blendars/"
echo "3. Configure .env file in /opt/blendars/infrastructure/"
echo "4. Run: cd /opt/blendars/infrastructure && docker-compose up -d"
echo ""
echo -e "${YELLOW}Ports opened:${NC}"
echo "  22   - SSH"
echo "  80   - HTTP"
echo "  443  - HTTPS"
echo "  7350 - Nakama HTTP"
echo "  7351 - Nakama Metrics"
echo "  7777 - Game Server TCP"
echo "  7778 - Game Server UDP"
echo ""
echo -e "${GREEN}Setup completed successfully!${NC}"
