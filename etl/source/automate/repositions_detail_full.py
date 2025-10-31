from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.table_manager import create_table_from_query
from etl.core.loaders.db_loader import load_to_db

def source_automate_repositions_detail():
    query_file = "source/automate/repositions_detail_full.sql"
    engine_src = get_engine("automate")
    engine_dest = get_engine("tatabi")

    create_table_from_query(
        query_file=query_file,
        source_db="automate",
        target_db="tatabi",
        target_table="repositions_detail",
        target_schema="source_automate",
        inspect_mode="select",
    )
    
    query = load_sql(query_file)
    rows = list(extract_from_db(engine_src, query))
    load_to_db(engine_dest, "source_automate.repositions_detail", rows)

if __name__ == "__main__":
    source_automate_repositions_detail()