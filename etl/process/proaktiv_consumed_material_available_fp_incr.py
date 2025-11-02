from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def process_proaktiv_consumed_material_available_fp():
    query_file = "process/proaktiv_consumed_material_available_fp_incr.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    upsert_to_db(engine_dest, "process.proaktiv_consumed_material_available_fp", rows, unique_keys=["material_code", "delete_row"])

if __name__ == "__main__":
    process_proaktiv_consumed_material_available_fp()
