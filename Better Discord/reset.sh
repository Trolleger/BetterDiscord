#!/bin/bash
echo "=== NUCLEAR RESET ==="
docker-compose down -v
docker system prune -a --volumes --force
docker network prune --force

echo "=== RECREATING NETWORK ==="
docker network create \
  --driver=bridge \
  --attachable \
  --subnet=172.20.0.0/16 \
  --ipv6 \
  --subnet=fd00:db8::/64 \
  betterdiscord

echo "=== STARTING COCKROACHDB ==="
docker-compose up -d --build cockroachdb

echo "=== WAITING FOR DATABASE (max 2 minutes) ==="
timeout 120 bash -c 'until docker-compose exec cockroachdb \
  ./cockroach sql --insecure -e "SELECT 1" &>/dev/null; do 
  sleep 5; 
  echo -n "."; 
done' || { echo -e "\nDATABASE FAILED TO START"; exit 1; }

echo -e "\n=== CREATING DATABASE ==="
docker-compose exec cockroachdb \
  ./cockroach sql --insecure -e "CREATE DATABASE IF NOT EXISTS chat_app_dev;"

echo "=== STARTING ALL SERVICES ==="
docker-compose up -d --build

echo "=== VERIFYING CONNECTION ==="
docker-compose exec backend \
  psql "postgresql://root@cockroachdb:26257/chat_app_dev?sslmode=disable" -c "SELECT 1" || \
  { echo "CONNECTION FAILED"; exit 1; }

echo "=== SYSTEM IS OPERATIONAL ==="