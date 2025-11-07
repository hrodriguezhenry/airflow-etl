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
import itertools

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


def _batched(iterable, n):
    """Yield lists of size up to n from an iterable."""
    it = iter(iterable)
    while True:
        chunk = list(itertools.islice(it, n))
        if not chunk:
            break
        yield chunk


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
    # Note: 'rows' can be a generator/iterator. Avoid truthiness checks that consume it.
    if rows is None:
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
        # Process in chunks, supporting both sequences and generators
        for batch in _batched(rows, batch_size):
            if not batch:
                continue

            with engine.begin() as conn:
                # Optimized path for a single unique key: set-based lookup + executemany
                if len(unique_keys) == 1:
                    ukey = unique_keys[0]

                    # Collect unique key values for the batch
                    key_values = [row[ukey] for row in batch]

                    # SQL Server has a 2100-parameter limit per statement.
                    # Split the IN clause into safe chunks when needed.
                    max_params = 2000 if dialect == "mssql" else len(key_values)
                    existing_keys = set()
                    for offset in range(0, len(key_values), max_params):
                        chunk_vals = key_values[offset:offset + max_params]
                        in_params = {f"k{i}": v for i, v in enumerate(chunk_vals)}
                        placeholders = ", ".join(f":k{i}" for i in range(len(chunk_vals)))
                        exists_sql = text(
                            f"SELECT {_quote_ident(ukey, dialect)} FROM {qtable} "
                            f"WHERE {_quote_ident(ukey, dialect)} IN ({placeholders})"
                        )
                        existing_rows = conn.execute(exists_sql, in_params).fetchall()
                        existing_keys.update(row[0] for row in existing_rows)

                    # Partition into updates and inserts
                    to_update = [r for r in batch if r[ukey] in existing_keys]
                    to_insert = [r for r in batch if r[ukey] not in existing_keys]

                    # Bulk UPDATE
                    if to_update:
                        non_keys = [c for c in to_update[0].keys() if c not in unique_keys]
                        if non_keys:
                            set_clause = ", ".join(
                                f"{_quote_ident(c, dialect)} = :{c}" for c in non_keys
                            )
                            where_clause = f"{_quote_ident(ukey, dialect)} = :{ukey}"
                            update_sql = text(f"UPDATE {qtable} SET {set_clause} WHERE {where_clause}")
                            conn.execute(update_sql, to_update)

                    # Bulk INSERT
                    if to_insert:
                        cols = list(to_insert[0].keys())
                        cols_quoted = ", ".join(_quote_ident(c, dialect) for c in cols)
                        values_clause = ", ".join(f":{c}" for c in cols)
                        insert_sql = text(f"INSERT INTO {qtable} ({cols_quoted}) VALUES ({values_clause})")
                        conn.execute(insert_sql, to_insert)

                else:
                    # Fallback for composite keys: row-by-row EXISTS + UPDATE/INSERT
                    for row in batch:
                        where_clause = " AND ".join(
                            [f"{_quote_ident(key, dialect)} = :{key}" for key in unique_keys]
                        )
                        params = {key: row[key] for key in unique_keys}

                        exists_query = text(
                            f"SELECT 1 WHERE EXISTS (SELECT 1 FROM {qtable} WHERE {where_clause})"
                        )
                        exists = conn.execute(exists_query, params).fetchone()

                        if exists:
                            set_clause = ", ".join(
                                [
                                    f"{_quote_ident(col, dialect)} = :{col}"
                                    for col in row.keys()
                                    if col not in unique_keys
                                ]
                            )
                            update_sql = text(f"UPDATE {qtable} SET {set_clause} WHERE {where_clause}")
                            conn.execute(update_sql, row)
                        else:
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
