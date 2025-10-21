from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]  
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.table_manager import create_table_from_query
from etl.core.loaders.db_loader import load_to_db

def accesorios_weeks():
    query_file = "source/accesorios/weeks_full.sql"
    
    create_table_from_query(
        query_file=query_file,
        source_db="accesorios",
        target_db="mysql_local",
        target_table="weeks",
        target_schema=None,
        inspect_mode="select"
    )
    
    engine_src = get_engine("accesorios")
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    
    engine_dest = get_engine("mysql_local")
    load_to_db(engine_dest, "weeks", rows)
    
if __name__ == "__main__":
    accesorios_weeks()
