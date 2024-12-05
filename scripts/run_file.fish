#!/usr/bin/fish

echo $argv

docker compose -f pg-compose.yml exec pg-dev psql -U postgres -d postgres -f /aoc/$argv/solution.sql