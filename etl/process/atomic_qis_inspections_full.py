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

def process_atomic_qis_inspections():
    query_file = "process/atomic_qis_inspections_full.sql"
    engine_src = get_engine("tatabi")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="tatabi",
        target_db="tatabi",
        target_table="atomic_qis_inspections",
        target_schema="process",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'paqi_revision_id_qr_id_inspection_date_station_id_atomic_line_id_atomic_stage_id_distribution_id_distribution_defect_id_defect_id_defect_stage_id')
        CREATE INDEX paqi_revision_id_qr_id_inspection_date_station_id_atomic_line_id_atomic_stage_id_distribution_id_distribution_defect_id_defect_id_defect_stage_id ON process.atomic_qis_inspections(revision_id, qr_id, inspection_date, station_id, atomic_line_id, atomic_stage_id, distribution_id, distribution_defect_id, defect_id, defect_stage_id);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "process.atomic_qis_inspections", rows)

if __name__ == "__main__":
    process_atomic_qis_inspections()
