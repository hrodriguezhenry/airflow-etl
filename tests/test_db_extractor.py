from pathlib import Path
import sys
from unittest.mock import MagicMock

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT_DIR))

from etl.core.extractors.db_extractor import extract_from_db

def test_extract_from_db_batches():
    # Simula el engine y la conexión
    fake_engine = MagicMock()
    fake_conn = fake_engine.connect.return_value.__enter__.return_value

    # Simula el comportamiento encadenado: execution_options().execute()
    fake_result = [
        MagicMock(_mapping={"id": 1, "name": "A"}),
        MagicMock(_mapping={"id": 2, "name": "B"}),
        MagicMock(_mapping={"id": 3, "name": "C"}),
    ]

    fake_exec_opts = MagicMock()
    fake_exec_opts.execute.return_value = iter(fake_result)
    fake_conn.execution_options.return_value = fake_exec_opts

    # Ejecuta la función
    results = list(extract_from_db(fake_engine, "SELECT * FROM test", batch_size=2))

    # Validaciones
    assert isinstance(results, list)
    assert len(results) == 3
    assert results[0]["name"] == "A"
    assert results[1]["id"] == 2