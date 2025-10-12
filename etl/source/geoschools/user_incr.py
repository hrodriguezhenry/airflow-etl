from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]  
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def geoschools_user():
    query_file = "source/geoschools/user_incr.sql"
    
    engine_src = get_engine("geoschools")
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    
    engine_dest = get_engine("dwh")
    upsert_to_db(engine_dest, "user", rows, unique_keys=["user_id"])
    
if __name__ == "__main__":
    geoschools_user()