from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_loader import load_to_db

def source_source_nesting_bills_materials():
    query_file = "source/source_nesting_bills/materials_incr.sql"
    engine_src = get_engine("nesting_bills")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_nesting_bills.materials", rows)

if __name__ == "__main__":
    source_source_nesting_bills_materials()