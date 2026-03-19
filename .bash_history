cd ~/mmorpg-server
mcedit docker-compose.yml
sudo du -sh /var/log/* | sort -rh | head -10
rm /var/log/journal
sudo apt install ncdu 
sudo ncdu /
exit
cd ~/mmorpg-server
mcedit docker-compose.yml
mc
docker compose logs -f
docker compose up -d
docker compose logs -f
mcedit docker-compose.yml
docker compose ps
curl http://localhost:7350/healthcheck
docker ps | grep mmorpg_nakama
docker logs mmorpg_nakama --tail 50
docker port mmorpg_nakama
docker exec mmorpg_nakama netstat -tulpn | grep 7350
docker exec -it mmorpg_nakama curl http://127.0.0.1:7350/
docker-compose restart mmorpg_nakama 
docker restart mmorpg_nakama 
docker ps
docker logs mmorpg_nakama --tail 50
docker port mmorpg_nakama
docker ps -a | grep mmorpg_nakama
curl http://127.0.0.1:7350/
curl "http://localhost:7350/v2/rpc/healthcheck?http_key=defaultkey"
docker stop mmorpg_nakama
docker inspect mmorpg_nakama | grep -A5 Mounts
exit
docker logs mmorpg_nakama --tail 50
'/home/gameserver/mmorpg-server/manage.sh'
'/home/gameserver/mmorpg-server/manage.sh'status
'/home/gameserver/mmorpg-server/manage.sh' status
