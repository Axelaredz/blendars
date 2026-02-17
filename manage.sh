#!/bin/bash
# ============================================
# MMORPG Server — Скрипт управления
# ============================================

PROJECT_DIR="$HOME/mmorpg-server"
cd "$PROJECT_DIR" || exit 1

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

    *)
        echo "Использование: $0 {start|stop|restart|logs|status}"
        echo "               $0 {godot-start|godot-stop|godot-logs}"
        echo "               $0 {backup|update-modules}"
        ;;
esac
