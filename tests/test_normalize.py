from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT_DIR))

from etl.core.transformers.normalize import normalize_strings, clean_emails

def test_normalize_strings():
    row = {'nombre': '  henry  ', 'ciudad': ' guatemala '}
    result = normalize_strings(row, ['nombre', 'ciudad'])
    assert result['nombre'] == 'HENRY'
    assert result['ciudad'] == 'GUATEMALA'

def test_clean_emails():
    row = {'email': '  Usuario@Dominio.Com '}
    result = clean_emails(row)
    assert result['email'] == 'usuario@dominio.com'