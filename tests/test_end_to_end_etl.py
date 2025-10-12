from pathlib import Path
import sys
import sqlalchemy as sa

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT_DIR))

from etl.core.extractors.db_extractor import extract_from_db
from etl.core.transformers.normalize import normalize_strings, clean_emails
from etl.core.loaders.db_loader import load_to_db

def test_end_to_end_etl(tmp_path):
    src_path = tmp_path / "src.db"
    src_engine = sa.create_engine(f"sqlite:///{src_path}")
    with src_engine.begin() as conn:
        conn.execute(sa.text("CREATE TABLE empleados (id INTEGER, nombre TEXT, email TEXT)"))
        conn.execute(sa.text("INSERT INTO empleados VALUES (1, ' ana ', 'ANA@MAIL.COM')"))
    rows = list(extract_from_db(src_engine, "SELECT * FROM empleados"))
    for r in rows:
        normalize_strings(r, ["nombre"])
        clean_emails(r)

    dst_path = tmp_path / "dst.db"
    dst_engine = sa.create_engine(f"sqlite:///{dst_path}")
    with dst_engine.begin() as conn:
        conn.execute(sa.text("CREATE TABLE empleados (id INTEGER, nombre TEXT, email TEXT)"))
    load_to_db(dst_engine, "empleados", rows)
    with dst_engine.connect() as conn:
        result = conn.execute(sa.text("SELECT nombre, email FROM empleados")).fetchone()

    assert result == ("ANA", "ana@mail.com")