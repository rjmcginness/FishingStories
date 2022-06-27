@ECHO OFF
set /p directory="Enter the full path to the directory for FishingStories."
cd directory
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements

docker compose up -d
cd data
cat fishing_stories.sql | docker exec -i fishing_container psql