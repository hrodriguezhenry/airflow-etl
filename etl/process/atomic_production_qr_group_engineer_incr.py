from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def process_atomic_production_qr_group_engineer():
    query_file = "process/atomic_production_qr_group_engineer_incr.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    upsert_to_db(engine_dest, "process.atomic_production_qr_group_engineer", rows, unique_keys=["qr_id", "group_close_stage_id", "group_close_line_id"])

if __name__ == "__main__":
    process_atomic_production_qr_group_engineer()
