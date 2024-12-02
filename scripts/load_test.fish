#!/usr/bin/fish

echo "Loading file for " $argv

echo "CREATE TABLE IF NOT EXISTS $argv;"

docker compose -f pg-compose.yml exec pg-dev psql -U postgres -c "CREATE TABLE IF NOT EXISTS $argv (values TEXT);"

echo "TRUNCATE TABLE $argv;"
docker compose -f pg-compose.yml exec pg-dev psql -U postgres -c "TRUNCATE TABLE $argv;"

echo ""
echo "COPY $argv FROM '/aoc/$argv/$argv.data'"
docker compose -f pg-compose.yml exec pg-dev psql -U postgres -c "COPY $argv FROM '/aoc/$argv/test.data'"
