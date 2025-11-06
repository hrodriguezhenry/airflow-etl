"""
Database upsert utilities for the ETL project.

This module provides a generic function to perform UPSERT operations
without requiring unique constraints in the target table.

The function compares rows using one or more key columns and performs
an UPDATE if a match exists, otherwise it performs an INSERT.

Currently supported:
    - MySQL
    - SQL Server

Example:
    from common.connections import get_engine
    from etl.core.loaders.db_upsert import upsert_to_db

    engine = get_engine("db_alias")
    rows = [
        {"id": 1, "value": "A"},
        {"id": 2, "value": "B"}
    ]
    upsert_to_db(engine, "target_table", rows, unique_keys=["id"], batch_size=1000)
"""

from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from common.logger import logger


def _quote_ident(name: str, dialect: str) -> str:
    """Quote an identifier for the given SQL dialect."""
    if dialect == "mssql":
        return f"[{name.replace(']', ']]')}]"
    if dialect == "mysql":
        return f"`{name.replace('`', '``')}`"
    # Fallback generic quoting
    return '"' + name.replace('"', '""') + '"'


def _format_qualified(name: str, dialect: str) -> str:
    """Quote a possibly schema-qualified name like schema.table."""
    parts = (name or "").split(".")
    return ".".join(_quote_ident(p, dialect) for p in parts if p)


def upsert_to_db(engine, table, rows, unique_keys, batch_size: int = 10000):
    """
    Perform a logical UPSERT (insert or update) into a database table.

    This function does not rely on database-level unique constraints.
    It checks for the existence of records using the provided unique keys
    and updates or inserts accordingly.

    Args:
        engine (sqlalchemy.engine.Engine):
            SQLAlchemy engine connected to the target database.
        table (str):
            Target table name.
        rows (Iterable[dict]):
            Rows to upsert, each represented as a dictionary
            (keys must match table columns).
        unique_keys (list[str]):
            List of column names that define uniqueness (one or more).
        batch_size (int, optional):
            Number of records to process per transaction batch (default: 10,000).

    Returns:
        int: Total number of rows processed (inserted or updated).

    Raises:
        ValueError: If no unique keys are provided.
        sqlalchemy.exc.SQLAlchemyError: If the UPSERT execution fails.
    """
    if not rows:
        logger.info(f"No records to upsert into {table}")
        return 0

    if not unique_keys:
        raise ValueError("At least one unique key must be provided for upsert validation.")

    total_rows = 0
    logger.info(
        f"Performing logical UPSERT into {table} using keys: {', '.join(unique_keys)} "
        f"(batch size = {batch_size})"
    )

    try:
        dialect = engine.dialect.name
        qtable = _format_qualified(table, dialect)
        # Process in chunks
        for i in range(0, len(rows), batch_size):
            batch = rows[i:i + batch_size]

            with engine.begin() as conn:
                for row in batch:
                    # Build WHERE clause for key comparison
                    where_clause = " AND ".join([f"{_quote_ident(key, dialect)} = :{key}" for key in unique_keys])
                    params = {key: row[key] for key in unique_keys}

                    # Check if record exists (use EXISTS to be dialect-agnostic, avoids LIMIT/TOP differences)
                    exists_query = text(
                        f"SELECT 1 WHERE EXISTS (SELECT 1 FROM {qtable} WHERE {where_clause})"
                    )
                    exists = conn.execute(exists_query, params).fetchone()

                    if exists:
                        # Prepare update statement excluding the key columns
                        set_clause = ", ".join(
                            [f"{_quote_ident(col, dialect)} = :{col}" for col in row.keys() if col not in unique_keys]
                        )
                        update_sql = text(f"UPDATE {qtable} SET {set_clause} WHERE {where_clause}")
                        conn.execute(update_sql, row)
                    else:
                        # Prepare insert statement
                        cols = ", ".join(_quote_ident(c, dialect) for c in row.keys())
                        placeholders = ", ".join([f":{c}" for c in row.keys()])
                        insert_sql = text(f"INSERT INTO {qtable} ({cols}) VALUES ({placeholders})")
                        conn.execute(insert_sql, row)

                total_rows += len(batch)
                logger.info(f"Processed {total_rows:,} records so far...")

        logger.info(f"UPSERT completed successfully: {total_rows:,} total records in {table}")
        return total_rows

    except SQLAlchemyError as e:
        logger.error(f"Logical UPSERT failed for {table}: {e}")
        raise
