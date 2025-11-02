from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def process_atomic_qis_inspections():
    query_file = "process/atomic_qis_inspections_incr.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    upsert_to_db(engine_dest, "process.atomic_qis_inspections", rows, unique_keys=["revision_id", "qr_id", "inspection_date", "station_id", "atomic_line_id", "atomic_stage_id", "distribution_id", "distribution_defect_id", "defect_id", "defect_stage_id"])

if __name__ == "__main__":
    process_atomic_qis_inspections()
