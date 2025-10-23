from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]  
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.table_manager import create_table_from_query
from etl.core.loaders.db_loader import load_to_db

def atomic_sfc_production_route():
    query_file = "source/atomic_sfc/production_route_full.sql"
    
    create_table_from_query(
        query_file=query_file,
        source_db="atomic",
        target_db="tatabi",
        target_table="source_atomic_sfc.production_route",
        target_schema=None,
        inspect_mode="select"
    )
    
    engine_src = get_engine("atomic")
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    
    engine_dest = get_engine("tatabi")
    load_to_db(engine_dest, "source_atomic_sfc.production_route", rows)
    
if __name__ == "__main__":
    atomic_sfc_production_route()