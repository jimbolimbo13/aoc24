# aoc24
Advent of code 2024 solutions

## How to use

### initialize
get postgres running: `docker compose -f pg-compose.yml up -d`

### pre-made scripts
- load day1 test data with `scripts/load_test day1`
- load day1 puzzle data with `scripts/load_puzzle day1`

_all load actions wipe out the table for that day_

- run the day1 solution with `scripts/run_file day1`

### ad-hoc things
(some of these are also in the `pg-compose.yml` file)

- enter a postgres shell `docker compose -f pg-compose.yml exec pg-dev psql -U postgres`
