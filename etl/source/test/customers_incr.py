from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def etl_customers():
    query_file = "source/test/customers_incr.sql"
    engine_src = get_engine("accesorios")
    engine_dest = get_engine("dwh")

    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    upsert_to_db(
        engine_dest,
        "customers",
        rows,
        unique_keys=["id"],
    )

if __name__ == "__main__":
    etl_customers()