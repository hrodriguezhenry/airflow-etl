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

def process_pdm_style_first():
    query_file = "process/pdm_style_first_full.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="tatabi",
        target_db="tatabi",
        target_table="pdm_style_first",
        target_schema="process",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'ppsf_style_id_input_field_id')
        CREATE INDEX ppsf_style_id_input_field_id ON process.pdm_style_first(style_id, input_field_id);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "process.pdm_style_first", rows)

if __name__ == "__main__":
    process_pdm_style_first()
