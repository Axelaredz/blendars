#!/bin/bash
# ============================================
# MMORPG Server — Скрипт управления
# ============================================
#
# LOCAL DEVELOPMENT (SSHFS):
# - Клиент запускается локально: Godot Editor → F5
# - Сервер развёртывается на VPS: ./manage.sh deploy
# - Файлы синхронизируются через sshfs
#
# REMOTE SERVER (VPS):
# - Все команды работают напрямую на сервере
# ============================================

PROJECT_DIR="${PROJECT_DIR:-$HOME/mmorpg-server}"
cd "$PROJECT_DIR" || exit 1

# Загрузка .env переменных
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
fi

case "$1" in
    # --- NAKAMA ---
    start)
        echo "🚀 Запускаем Nakama..."
        docker compose up -d
        echo "✅ Nakama запущена"
        ;;
    stop)
        echo "⏹️  Останавливаем Nakama..."
        docker compose down
        echo "✅ Nakama остановлена"
        ;;
    restart)
        echo "🔄 Перезапускаем Nakama..."
        docker compose restart
        echo "✅ Nakama перезапущена"
        ;;
    logs)
        docker compose logs -f --tail=100
        ;;
    status)
        echo "=== Docker контейнеры ==="
        docker compose ps
        echo ""
        echo "=== Godot Server ==="
        sudo systemctl status godot-server --no-pager
        echo ""
        echo "=== Использование диска ==="
        df -h /
        echo ""
        echo "=== Память ==="
        free -h
        ;;

    # --- GODOT ---
    godot-start)
        echo "🎮 Запускаем Godot Server..."
        sudo systemctl start godot-server
        echo "✅ Godot Server запущен"
        ;;
    godot-stop)
        echo "⏹️  Останавливаем Godot Server..."
        sudo systemctl stop godot-server
        ;;
    godot-logs)
        tail -f "$PROJECT_DIR/logs/godot-server.log"
        ;;

    # --- ОБСЛУЖИВАНИЕ ---
    backup)
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        echo "💾 Создаём бэкап базы данных..."
        docker compose exec -T postgres \
            pg_dump -U nakama_user nakama > "$PROJECT_DIR/data/$BACKUP_FILE"
        echo "✅ Бэкап сохранён: data/$BACKUP_FILE"
        ;;
    update-modules)
        echo "🔄 Обновляем серверные модули..."
        docker compose restart nakama
        echo "✅ Модули перезагружены"
        ;;

    # --- DEPLOY TO VPS (LOCAL DEVELOPMENT) ---
    deploy)
        echo "🚀 Деплой на VPS (Nakama + Godot Server)..."
        
        # Проверка подключения к VPS
        if [ -z "$VPS_HOST" ] || [ -z "$VPS_USER" ]; then
            echo "❌ Ошибка: VPS_HOST и VPS_USER не настроены в .env"
            exit 1
        fi
        
        # Деплой Nakama модулей
        echo "📦 Копируем Nakama модули..."
        scp -r nakama-server/src/* "$VPS_USER@$VPS_HOST:/opt/blendars/infrastructure/nakama_modules/"
        
        # Перезапуск Nakama
        echo "🔄 Перезапускаем Nakama..."
        ssh "$VPS_USER@$VPS_HOST" "cd /opt/blendars/infrastructure && docker compose restart nakama"
        
        # Деплой Godot сервера
        echo "🎮 Деплой Godot сервера..."
        scp godot-project/src/shared/protocol.gd "$VPS_USER@$VPS_HOST:/opt/blendars/godot-project/src/shared/"
        scp godot-project/src/server/server_main.gd "$VPS_USER@$VPS_HOST:/opt/blendars/godot-project/src/server/"
        
        echo "✅ Деплой завершён!"
        echo ""
        echo "Для запуска клиента локально:"
        echo "  godot --path godot-project/ --editor"
        ;;
    deploy-nakama)
        echo "🚀 Деплой Nakama на VPS..."
        
        if [ -z "$VPS_HOST" ] || [ -z "$VPS_USER" ]; then
            echo "❌ Ошибка: VPS_HOST и VPS_USER не настроены в .env"
            exit 1
        fi
        
        echo "📦 Копируем Nakama модули..."
        scp -r nakama-server/src/* "$VPS_USER@$VPS_HOST:/opt/blendars/infrastructure/nakama_modules/"
        
        echo "🔄 Перезапускаем Nakama..."
        ssh "$VPS_USER@$VPS_HOST" "cd /opt/blendars/infrastructure && docker compose restart nakama"
        
        echo "✅ Nakama обновлён!"
        ;;
    deploy-server)
        echo "🚀 Деплой Godot сервера на VPS..."
        
        if [ -z "$VPS_HOST" ] || [ -z "$VPS_USER" ]; then
            echo "❌ Ошибка: VPS_HOST и VPS_USER не настроены в .env"
            exit 1
        fi
        
        echo "📦 Копируем файлы сервера..."
        scp godot-project/src/shared/protocol.gd "$VPS_USER@$VPS_HOST:/opt/blendars/godot-project/src/shared/"
        scp godot-project/src/server/server_main.gd "$VPS_USER@$VPS_HOST:/opt/blendars/godot-project/src/server/"
        
        echo "✅ Godot сервер обновлён!"
        ;;

    *)
        echo "Использование: $0 {start|stop|restart|logs|status}"
        echo "               $0 {godot-start|godot-stop|godot-logs}"
        echo "               $0 {backup|update-modules}"
        echo "               $0 {deploy|deploy-nakama|deploy-server}"
        echo ""
        echo "LOCAL DEVELOPMENT (SSHFS):"
        echo "  deploy         - Полный деплой на VPS (Nakama + Godot server)"
        echo "  deploy-nakama  - Деплой только Nakama"
        echo "  deploy-server  - Деплой только Godot server"
        echo ""
        echo "Пример запуска клиента локально:"
        echo "  godot --path godot-project/ --editor"
        echo "  или в Godot Editor: F5"
        ;;
esac
