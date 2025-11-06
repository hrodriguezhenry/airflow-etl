from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.table_manager import create_table_from_query
from etl.core.loaders.db_loader import load_to_db

def geoschools_department():
    query_file = "source/geoschools/department_full.sql"
    engine_src = get_engine("geoschools")
    engine_dest = get_engine("dwh")

    create_table_from_query(
        query_file=query_file,
        source_db="geoschools",
        target_db="dwh",
        target_table="department",
        target_schema=None,
        inspect_mode="select",
    )
    
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "department", rows)

if __name__ == "__main__":
    geoschools_department()