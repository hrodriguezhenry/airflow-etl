"""
Database loading utilities for the ETL project.

This module provides a helper function to load data into a target
database table using SQLAlchemy, supporting batch inserts to
optimize performance.

Functions:
    - load_to_db(engine, table, rows, batch_size=10000, mode="append"):
      Insert rows into a database table in batches.

Example:
    from common.db_loader import load_to_db
    from common.connections import get_engine

    engine = get_engine("db_alias")
    rows = [
        {"id": 1, "value": "A"},
        {"id": 2, "value": "B"}
    ]
    load_to_db(engine, "target_table", rows, batch_size=1000)
"""

from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from sqlalchemy import insert, text
from sqlalchemy.sql import table as sa_table, column as sa_column
from common.logger import logger

def load_to_db(engine, table, rows, batch_size: int = 10000, mode="append"):
    """
    Insert rows into a database table in batches.

    Args:
        engine (sqlalchemy.engine.Engine): Database engine.
        table (str): Target table name.
        rows (Iterable[dict]): Rows to insert.
        batch_size (int, optional): Rows per batch. Default 10,000.
        mode (str, optional): "append" (default) or "replace" (truncate before load).

    Returns:
        int: Total number of rows inserted.
    """
    if not rows:
        logger.warning(f"No records to load into {table}")
        return 0

    # Split schema if provided
    if "." in table:
        schema, tbl_name = table.split(".", 1)
        full_table_name = f"{schema}.{tbl_name}"
    else:
        schema, tbl_name = None, table
        full_table_name = table

    with engine.connect() as conn:
        if mode == "replace":
            logger.info(f"Truncating table {full_table_name} before load...")
            try:
                conn.execute(text(f"TRUNCATE TABLE {full_table_name}"))
                conn.commit()
                logger.info(f"Table {full_table_name} truncated successfully.")
            except Exception as e:
                logger.warning(f"TRUNCATE not supported, attempting DELETE FROM {full_table_name}")
                conn.execute(text(f"DELETE FROM {full_table_name}"))
                conn.commit()
                logger.info(f"All records deleted from {full_table_name}.")
        elif mode != "append":
            raise ValueError(f"Unsupported mode '{mode}'. Use 'append' or 'replace'.")

        rows_copied = 0
        buffer = []
        insert_stmt = None
        trans = conn.begin()
        for row in rows:
            buffer.append(row)
            if insert_stmt is None:
                cols = list(row.keys())
                tbl = sa_table(tbl_name, *[sa_column(c) for c in cols], schema=schema)
                insert_stmt = insert(tbl)

            if len(buffer) >= batch_size:
                conn.execute(insert_stmt, buffer)
                trans.commit()
                trans = conn.begin()
                rows_copied += len(buffer)
                logger.info(f"{rows_copied:,} records inserted into {full_table_name}")
                buffer.clear()

        if buffer:
            conn.execute(insert_stmt, buffer)
            trans.commit()
            rows_copied += len(buffer)

    logger.info(f"Process completed: {rows_copied:,} total records loaded into {full_table_name}")
    return rows_copied