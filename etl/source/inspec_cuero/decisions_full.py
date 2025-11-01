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

def source_inspec_cuero_decisions():
    query_file = "source/inspec_cuero/decisions_full.sql"
    engine_src = get_engine("inspec_cuero")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="inspec_cuero",
        target_db="tatabi",
        target_table="decisions",
        target_schema="source_inspec_cuero",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'sicd_id')
        CREATE INDEX sicd_id ON source_inspec_cuero.decisions(id);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_inspec_cuero.decisions", rows)

if __name__ == "__main__":
    source_inspec_cuero_decisions()