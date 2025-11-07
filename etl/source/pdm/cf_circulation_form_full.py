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

def source_pdm_cf_circulation_form():
    query_file = "source/pdm/cf_circulation_form_full.sql"
    engine_src = get_engine("pdm")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="pdm",
        target_db="tatabi",
        target_table="cf_circulation_form",
        target_schema="source_pdm",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'spccf_id')
        CREATE INDEX spccf_id ON source_pdm.cf_circulation_form(id);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    load_to_db(engine_dest, "source_pdm.cf_circulation_form", rows)

if __name__ == "__main__":
    source_pdm_cf_circulation_form()