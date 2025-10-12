from sqlalchemy import text

def run_sql_file(engine, file_path):
    """Ejecuta un archivo SQL en el motor dado."""
    with open(file_path, "r", encoding="utf-8") as f:
        sql_script = f.read()
    with engine.begin() as conn:
        conn.execute(text(sql_script))
    print(f"Script {file_path} ejecutado con éxito")