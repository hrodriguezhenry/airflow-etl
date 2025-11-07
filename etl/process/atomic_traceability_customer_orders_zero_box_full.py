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

def process_atomic_traceability_customer_orders_zero_box():
    query_file = "process/atomic_traceability_customer_orders_zero_box_full.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="tatabi",
        target_db="tatabi",
        target_table="atomic_traceability_customer_orders_zero_box",
        target_schema="process",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'patcozb_cust_ord_style_id_qr_id_date')
        CREATE INDEX patcozb_cust_ord_style_id_qr_id_date ON process.atomic_traceability_customer_orders_zero_box(cust_ord, style_id, qr_id, date);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    load_to_db(engine_dest, "process.atomic_traceability_customer_orders_zero_box", rows)

if __name__ == "__main__":
    process_atomic_traceability_customer_orders_zero_box()
