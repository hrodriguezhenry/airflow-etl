from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_upsert import upsert_to_db

def source_proaktiv_aut_peps_pt():
    query_file = "source/proaktiv/aut_peps_pt_incr.sql"
    engine_src = get_engine("proaktiv")
    engine_dest = get_engine("tatabi")

    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    upsert_to_db(
        engine_dest,
        "source_proaktiv.aut_peps_pt",
        rows,
        unique_keys=["id_authorization"],
    )

if __name__ == "__main__":
    source_proaktiv_aut_peps_pt()
