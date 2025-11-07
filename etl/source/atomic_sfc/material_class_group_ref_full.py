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

def source_atomic_sfc_material_class_group_ref():
    query_file = "source/atomic_sfc/material_class_group_ref_full.sql"
    engine_src = get_engine("atomic")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="atomic",
        target_db="tatabi",
        target_table="material_class_group_ref",
        target_schema="source_atomic_sfc",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'sasmcgr_id')
        CREATE INDEX sasmcgr_id ON source_atomic_sfc.material_class_group_ref(id);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    load_to_db(engine_dest, "source_atomic_sfc.material_class_group_ref", rows)

if __name__ == "__main__":
    source_atomic_sfc_material_class_group_ref()