from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def process_sam_specific_all():
    query_file = "process/sam_specific_all_incr.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    upsert_to_db(engine_dest, "process.sam_specific_all", rows, unique_keys=["route_id", "style_id", "sam_id", "sam_specific_id", "stage", "class_group_id"])

if __name__ == "__main__":
    process_sam_specific_all()
