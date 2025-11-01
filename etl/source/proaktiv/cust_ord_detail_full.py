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

def source_proaktiv_cust_ord_detail():
    query_file = "source/proaktiv/cust_ord_detail_full.sql"
    engine_src = get_engine("proaktiv")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="proaktiv",
        target_db="tatabi",
        target_table="cust_ord_detail",
        target_schema="source_proaktiv",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'spcod_cust_ord_detail')
        CREATE INDEX spcod_cust_ord_detail ON source_proaktiv.cust_ord_detail(cust_ord_hdr_number, stl_number, clr_number, sz_dim_det_number, cust_ord_det_qty);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_proaktiv.cust_ord_detail", rows)

if __name__ == "__main__":
    source_proaktiv_cust_ord_detail()