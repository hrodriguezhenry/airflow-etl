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

from sqlalchemy import insert
from sqlalchemy.sql import table as sa_table, column as sa_column
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
    insert_stmt = None

    # Reuse a single connection and commit per batch to reduce overhead.
    with engine.connect() as conn:
        trans = conn.begin()
        for row in rows:
            buffer.append(row)

            if insert_stmt is None:
                # Build a dialect-aware INSERT using SQLAlchemy Core so that
                # drivers like mssql+pyodbc can leverage fast_executemany.
                cols = list(row.keys())
                # Support optional schema in table name (e.g., "dbo.customers").
                if "." in table:
                    schema, tbl_name = table.split(".", 1)
                else:
                    schema, tbl_name = None, table

                tbl = sa_table(tbl_name, *[sa_column(c) for c in cols], schema=schema)
                insert_stmt = insert(tbl)

            if len(buffer) >= batch_size:
                conn.execute(insert_stmt, buffer)
                trans.commit()
                trans = conn.begin()
                rows_copied += len(buffer)
                logger.info(f"{rows_copied:,} records inserted into {table}")
                buffer.clear()

        if buffer:
            conn.execute(insert_stmt, buffer)
            trans.commit()
            rows_copied += len(buffer)

    logger.info(f"Process completed: {rows_copied:,} total records in {table}")
    return rows_copied
