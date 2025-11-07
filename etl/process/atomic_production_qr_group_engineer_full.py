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

def process_atomic_production_qr_group_engineer():
    query_file = "process/atomic_production_qr_group_engineer_full.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="tatabi",
        target_db="tatabi",
        target_table="atomic_production_qr_group_engineer",
        target_schema="process",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'papqge_qr_id_group_close_stage_id_group_close_line_id')
        CREATE INDEX papqge_qr_id_group_close_stage_id_group_close_line_id ON process.atomic_production_qr_group_engineer(qr_id, group_close_stage_id, group_close_line_id);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    load_to_db(engine_dest, "process.atomic_production_qr_group_engineer", rows)

if __name__ == "__main__":
    process_atomic_production_qr_group_engineer()
