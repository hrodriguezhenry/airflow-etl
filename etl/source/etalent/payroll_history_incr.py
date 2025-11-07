from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def source_etalent_payroll_history():
    query_file = "source/etalent/payroll_history_incr.sql"
    engine_src = get_engine("etalent")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    upsert_to_db(
        engine_dest,
        "source_etalent.payroll_history",
        rows,
        unique_keys=["cod_company", "cod_type_payroll", "cod_payroll", "cod_employee"],
    )

if __name__ == "__main__":
    source_etalent_payroll_history()