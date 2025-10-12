from pathlib import Path
import sys
import sqlalchemy as sa

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT_DIR))

from etl.core.loaders.db_loader import load_to_db

def test_load_to_db_sqlite(tmp_path):
    db_path = tmp_path / "test.db"
    engine = sa.create_engine(f"sqlite:///{db_path}")
    
    with engine.begin() as conn:
        conn.execute(sa.text("CREATE TABLE usuarios (id INTEGER, nombre TEXT)"))
        
    rows = [
        {"id": 1, "nombre": "HENRY"},
        {"id": 2, "nombre": "ANA"}
    ]
    load_to_db(engine, "usuarios", rows, batch_size=1, mode="append")
    
    with engine.connect() as conn:
        result = conn.execute(sa.text("SELECT COUNT(*) FROM usuarios")).scalar()
        assert result == 2
