#!/bin/bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

docker compose up -d
cd data
cat fishing_stories.sql | docker exec -i fishing_container psql