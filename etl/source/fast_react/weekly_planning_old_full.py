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

def source_fast_react_weekly_planning_old():
    query_file = "source/fast_react/weekly_planning_old_full.sql"
    engine_src = get_engine("fast_react")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="fast_react",
        target_db="tatabi",
        target_table="weekly_planning_old",
        target_schema="source_fast_react",
        inspect_mode="select",
    )

    sql_script = [
        """
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'sfrwpo_cust_ord')
        CREATE INDEX sfrwpo_cust_ord ON source_fast_react.weekly_planning_old(cust_ord);
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'sfrwo_planning_date')
        CREATE INDEX sfrwo_planning_date ON source_fast_react.weekly_planning_old(planning_date);
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'sfrwpo_stage')
        CREATE INDEX sfrwpo_stage ON source_fast_react.weekly_planning_old(stage);
        IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'sfrwpo_week')
        CREATE INDEX sfrwpo_week ON source_fast_react.weekly_planning_old(week);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_fast_react.weekly_planning_old", rows)

if __name__ == "__main__":
    source_fast_react_weekly_planning_old()