from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]  
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def accesorios_weeks():
    query_file = "source/accesorios/weeks_incr.sql"
    
    engine_src = get_engine("accesorios")
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    
    engine_dest = get_engine("mysql_local")
    upsert_to_db(engine_dest, "weeks", rows, unique_keys=["day"])
    
if __name__ == "__main__":
    accesorios_weeks()