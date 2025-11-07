from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from common.connections import get_engine
from common.utils import load_sql
from etl.core.extractors.db_extractor import extract_from_db
from etl.core.loaders.db_loader import load_to_db
from etl.core.sql.scripts import run_sql_script

def source_etalent_liquidation_collaborator():
    query_file = "source/etalent/liquidation_collaborator_incr.sql"
    engine_src = get_engine("etalent")
    engine_dest = get_engine("tatabi")
    
    sql_script = [
        """
        DELETE FROM source_etalent.liquidation_collaborator
        WHERE withdrawal_date >= CONVERT(date, GETDATE() -14);
        """,
    ]

    run_sql_script(engine_dest, sql_script)
    query = load_sql(query_file)
    rows = extract_from_db(engine_src, query)
    load_to_db(engine_dest, "source_etalent.liquidation_collaborator", rows)

if __name__ == "__main__":
    source_etalent_liquidation_collaborator()