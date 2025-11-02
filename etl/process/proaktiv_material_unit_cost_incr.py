from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def process_proaktiv_material_unit_cost():
    query_file = "process/proaktiv_material_unit_cost_incr.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    upsert_to_db(engine_dest, "process.proaktiv_material_unit_cost", rows, unique_keys=["row_hash", "doc_entry", "doc_date", "card_code", "material_code", "purchase_order_date", "purchase_order", "currency", "unit_price", "unit_cost"])

if __name__ == "__main__":
    process_proaktiv_material_unit_cost()
