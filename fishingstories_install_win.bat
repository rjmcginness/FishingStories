@ECHO OFF
python -m venv .venv
.venv/bin/activate
pip install -r requirements.txt

docker compose up -d
cd data
type fishing_stories.sql | docker exec -i fishing_container psql