from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.table_manager import create_table_from_query
from etl.core.loaders.db_loader import load_to_db
from etl.core.sql.scripts import run_sql_script

def source_proaktiv_cust_ord_aud():
    query_file = "source/proaktiv/cust_ord_aud_full.sql"
    engine_src = get_engine("proaktiv")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="proaktiv",
        target_db="tatabi",
        target_table="cust_ord_aud",
        target_schema="source_proaktiv",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'spcoa_cust_ord_aud_corr')
        CREATE INDEX spcoa_cust_ord_aud_corr ON source_proaktiv.cust_ord_aud(cust_ord_aud_corr);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_proaktiv.cust_ord_aud", rows)

if __name__ == "__main__":
    source_proaktiv_cust_ord_aud()