"""
Database extraction utilities for the ETL project.

This module provides a helper function to stream rows from a database
query in batches, yielding each row as a dictionary. It is designed to
handle large result sets efficiently without loading everything into memory.

Functions:
    - extract_from_db(engine, query, batch_size=10000):
      Stream query results as dictionaries.

Example:
    from common.db_extractor import extract_from_db
    from common.connections import get_engine

    engine = get_engine("db_alias")
    query = "SELECT id, col1, col2 FROM target_table"

    for row in extract_from_db(engine, query, batch_size=5000):
        print(row)
        # {'id': 1, 'col1': 'Value A', 'col2': 'Value B'}
"""

from sqlalchemy import text


def extract_from_db(engine, query, batch_size=10000):
    """
    Stream rows from a database query as dictionaries.

    Args:
        engine (sqlalchemy.engine.Engine):
            SQLAlchemy engine connected to the source database.
        query (str):
            SQL query string to execute.
        batch_size (int, optional):
            Number of rows to fetch per batch (default: 10,000).
            Note: Depending on the database and driver, this may or may not
            affect how results are streamed.

    Yields:
        dict: A row from the query result, with column names as keys.

    Example:
        >>> engine = get_engine("db_alias")
        >>> query = "SELECT id, col1, col2 FROM target_table"
        >>> for row in extract_from_db(engine, query, batch_size=5000):
        ...     print(row)
        {'id': 1, 'col1': 'Value A', 'col2': 'Value B'}
    """
    with engine.connect() as conn:
        result = conn.execution_options(stream_results=True).execute(text(query))
        for row in result:
            yield dict(row._mapping)
