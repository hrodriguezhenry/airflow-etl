from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def source_automate_standard_head_count():
    query_file = "source/automate/standard_head_count_incr.sql"
    engine_src = get_engine("automate")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    upsert_to_db(
        engine_dest,
        "source_automate.standard_head_count",
        rows,
        unique_keys=["end_date", "cost_center"],
    )

if __name__ == "__main__":
    source_automate_standard_head_count()