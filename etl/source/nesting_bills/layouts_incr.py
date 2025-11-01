from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def source_nesting_bills_layouts():
    query_file = "source/nesting_bills/layouts_incr.sql"
    engine_src = get_engine("nesting_bills")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    upsert_to_db(
        engine_dest,
        "source_nesting_bills.layouts",
        rows,
        unique_keys=["layout_id"],
    )

if __name__ == "__main__":
    source_nesting_bills_layouts()