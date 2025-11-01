from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_loader import load_to_db
from etl.core.sql.scripts import run_sql_script

def source_proaktiv_exch_rate_multi():
    query_file = "source/proaktiv/exch_rate_multi_incr.sql"
    engine_src = get_engine("proaktiv")
    engine_dest = get_engine("tatabi")
    
    sql_script = [
        """
        IF NOT EXISTS (
            SELECT name
            FROM sysindexes
            WHERE name = 'sperm_exch_curr_code_orig_exch_curr_code_dest_exch_date'
        )
        CREATE INDEX sperm_exch_curr_code_orig_exch_curr_code_dest_exch_date
        ON source_proaktiv.exch_rate_multi(exch_curr_code_orig, exch_curr_code_dest, exch_date);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_proaktiv.exch_rate_multi", rows)

if __name__ == "__main__":
    source_proaktiv_exch_rate_multi()
