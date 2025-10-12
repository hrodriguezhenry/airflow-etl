from pathlib import Path
import sys
import pytest

ROOT_DIR = Path(__file__).resolve().parents[1]  
sys.path.insert(0, str(ROOT_DIR))

from common.utils import load_sql

def test_load_sql_reads_file(tmp_path):
    queries_dir = Path(__file__).resolve().parent.parent / "queries"
    queries_dir.mkdir(exist_ok=True)
    
    sql_file = queries_dir / "test.sql"
    sql_file.write_text("SELECT 1;", encoding="utf-8")
    
    content = load_sql("test.sql")
    assert content.strip() == "SELECT 1;"
    
    sql_file.unlink()
    
def test_load_sql_file_not_found():
    with pytest.raises(FileNotFoundError):
        load_sql("non_existent_file.sql")