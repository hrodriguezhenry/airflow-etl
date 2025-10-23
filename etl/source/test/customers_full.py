from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]  
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.transformers.normalize import normalize_strings
from etl.core.loaders.table_manager import create_table_from_query
from etl.core.loaders.db_loader import load_to_db

def etl_customers():
    query_file = "source/test/customers_full.sql"
    
    # 1. Create table
    create_table_from_query(
        query_file=query_file,
        source_db="accesorios",
        target_db="sqlserver1",
        target_table="customers",
        target_schema=None
    )

    # 2. Extract
    engine_src = get_engine("accesorios")
    query = load_sql(query_file)
    rows_stream = extract_from_db(engine_src, query)

    # 3. Transform
    rows = (normalize_strings(r, ["nombre"]) for r in rows_stream)

    # 4. Load
    engine_dest = get_engine("sqlserver1")
    load_to_db(engine_dest, "customers", rows, batch_size=10000)
    
if __name__ == "__main__":
    etl_customers()
