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

def MarcajesHickvision():
    query_file1 = "legacy/DWHMySQL/ArchivosExcel/MarcajesHickvision/Hikvision.sql"
    query_file2 = "legacy/DWHMySQL/ArchivosExcel/MarcajesHickvision/DataeTalent.sql"
    query_file3 = "legacy/DWHMySQL/ArchivosExcel/MarcajesHickvision/TATAERP.sql"
    
    # Extract
    engine_src = get_engine("hickvision")
    query = load_sql(query_file1)
    rows_stream = extract_from_db(engine_src, query)
    
    engine_src = get_engine("dwh")
    query = load_sql(query_file2)
    rows_stream = extract_from_db(engine_src, query)
    
    engine_src = get_engine("tata_erp")
    query = load_sql(query_file3)
    rows_stream = extract_from_db(engine_src, query)

    # Load
    engine_dest = get_engine("dwh")
    load_to_db(engine_dest, "Hikvision_Marcajes", rows_stream, batch_size=10000, mode="replace")
    
if __name__ == "__main__":
    MarcajesHickvision()