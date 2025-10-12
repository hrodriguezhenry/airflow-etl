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

from sqlalchemy import text
from common.logger import logger

def load_to_db(engine, table, rows, batch_size: int = 10000, mode="append"):
    """
    Insert rows into a database table in batches.

    Args:
        engine (sqlalchemy.engine.Engine):
            SQLAlchemy engine connected to the target database.
        table (str):
            Target table name where rows will be inserted.
        rows (Iterable[dict]):
            Rows to insert, each row represented as a dictionary
            (keys must match table columns).
        batch_size (int, optional):
            Number of rows per batch insert (default: 10,000).
        mode (str, optional):
            Insert mode. Currently only "append" is supported.

    Returns:
        int: Total number of rows inserted.

    Raises:
        sqlalchemy.exc.SQLAlchemyError: If any database error occurs.

    Example:
        >>> engine = get_engine("db_alias")
        >>> rows = [{"id": 1, "value": "A"}, {"id": 2, "value": "B"}]
        >>> load_to_db(engine, "target_table", rows, batch_size=1000)
        2
    """
    rows_copied = 0
    buffer = []
    insert_sql = None

    for row in rows:
        buffer.append(row)

        if insert_sql is None:
            cols = row.keys()
            col_names = ", ".join(cols)
            placeholders = ", ".join([f":{c}" for c in cols])
            insert_sql = text(f"INSERT INTO {table} ({col_names}) VALUES ({placeholders})")

        if len(buffer) >= batch_size:
            with engine.begin() as conn:
                conn.execute(insert_sql, buffer)
            rows_copied += len(buffer)
            logger.info(f"{rows_copied:,} records inserted into {table}")
            buffer.clear()

    if buffer:
        with engine.begin() as conn:
            conn.execute(insert_sql, buffer)
        rows_copied += len(buffer)

    logger.info(f"Process completed: {rows_copied:,} total records in {table}")
    return rows_copied
