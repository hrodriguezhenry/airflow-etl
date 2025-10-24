from sqlalchemy import text

def run_sql_script(engine, sql_script: str):
    with engine.begin() as conn:
        for stmt in sql_script:
            conn.execute(text(stmt))


def run_sql_file(engine, file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        sql_script = f.read()
    with engine.begin() as conn:
        conn.execute(text(sql_script))