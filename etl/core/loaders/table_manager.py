"""
Table management utilities for the ETL project.

This module provides helper functions to:
    - Create or replace database views in a dialect-safe way.
    - Drop views safely across supported engines.
    - Create a target table dynamically from the metadata of a SQL query,
      using a temporary view for schema inspection.

Supported drivers:
    - MySQL
    - PostgreSQL
    - SQL Server
    - Oracle
    - SAP HANA

Example:
    from common.table_manager import create_table_from_query

    create_table_from_query(
        query_file="queries/source_table.sql",
        source_db="db_alias_source",
        target_db="db_alias_target",
        target_table="target_table",
    )
"""

from pathlib import Path
import sys

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from sqlalchemy import text, MetaData, Table, Column, String, inspect
from common.connections import get_engine
from common.utils import load_sql
from common.logger import logger
from common.type_mapping.generic import map_type

def create_or_replace_view(conn, dialect: str, view_name: str, query: str):
    """
    Create or replace a view in a dialect-compatible way.

    Args:
        conn (sqlalchemy.engine.Connection): Active database connection.
        dialect (str): Database dialect name (mysql, postgresql, mssql, oracle, hana).
        view_name (str): Name of the view to create or replace.
        query (str): SQL query that defines the view.
    """
    dialect = dialect.lower()

    if "mysql" in dialect or "postgresql" in dialect or "hana" in dialect:
        conn.execute(text(f"CREATE OR REPLACE VIEW {view_name} AS {query}"))
    elif "mssql" in dialect:
        conn.execute(text(f"IF OBJECT_ID('{view_name}', 'V') IS NOT NULL DROP VIEW {view_name}"))
        conn.execute(text(f"CREATE VIEW {view_name} AS {query}"))
    elif "oracle" in dialect:
        conn.execute(text(f"CREATE OR REPLACE VIEW {view_name} AS {query}"))
    else:
        logger.error(f"Dialect '{dialect}' not supported")


def drop_view(conn, dialect: str, view_name: str):
    """
    Drop a view safely across supported databases.

    Args:
        conn (sqlalchemy.engine.Connection): Active database connection.
        dialect (str): Database dialect name (mysql, postgresql, mssql, oracle, hana).
        view_name (str): Name of the view to drop.
    """
    dialect = dialect.lower()
    if "mssql" in dialect:
        conn.execute(text(f"IF OBJECT_ID('{view_name}', 'V') IS NOT NULL DROP VIEW {view_name}"))
    else:
        conn.execute(text(f"DROP VIEW IF EXISTS {view_name}"))


def create_table_from_query(
        query_file: str,
        source_db: str,
        target_db: str,
        target_table: str,
        overrides: dict = None,
        target_schema: str = None,
    ):
    """
    Create a target table based on the metadata of a query.

    The function:
        1. Creates a temporary view in the source database from the query.
        2. Inspects column metadata from the temporary view.
        3. Maps database-specific types to SQLAlchemy types.
        4. Applies column overrides (if provided).
        5. Creates (or replaces) the table in the target database.
        6. Drops the temporary view in the source database.

    Args:
        query_file (str): Path to the SQL file containing the query.
        source_db (str): Alias of the source database (must exist in db_connections.yaml).
        target_db (str): Alias of the target database (must exist in db_connections.yaml).
        target_table (str): Name of the table to create in the target database.
        overrides (dict, optional): Column overrides by name.
            Example: {"col1": {"type": String(500)}, "col2": {"length": 50}}
        target_schema (str, optional): Schema to use in the target database.
            Defaults to "dbo" for SQL Server if not provided.

    Raises:
        Exception: If table creation fails at any step.

    Example:
        >>> create_table_from_query(
        ...     query_file="queries/my_query.sql",
        ...     source_db="db_alias_source",
        ...     target_db="db_alias_target",
        ...     target_table="target_table",
        ...     overrides={"col1": {"length": 200}}
        ... )
    """
    engine_src = get_engine(source_db)
    engine_dest = get_engine(target_db)
    query = load_sql(query_file)

    view_name = f"tmp_view_{target_table}"

    try:
        # 1. Create temporary view
        with engine_src.connect() as conn_src:
            create_or_replace_view(conn_src, engine_src.dialect.name, view_name, query)
            logger.info(f"Temporary view {view_name} created in {source_db}")

        # 2. Inspect columns from view
        insp = inspect(engine_src)
        col_meta = insp.get_columns(view_name, schema=source_db)

        columns = []
        for meta in col_meta:
            col_name = meta["name"]
            col_type = meta["type"]
            length = getattr(col_type, "length", None)

            # Map to SQLAlchemy type
            sa_type = map_type(
                db_type=col_type,
                source=engine_src.dialect.name,
                length=length,
            )

            # Apply overrides
            if overrides and col_name in overrides:
                ov = overrides[col_name]
                if "type" in ov:
                    sa_type = ov["type"]
                elif "length" in ov and isinstance(sa_type, String):
                    sa_type = String(ov["length"])

            columns.append(Column(col_name, sa_type))

        schema_to_use = target_schema
        if engine_dest.dialect.name == "mssql" and not target_schema:
            schema_to_use = "dbo"

        # 3. Create table in target
        metadata = MetaData()
        table = Table(target_table, metadata, *columns, schema=schema_to_use)
        metadata.drop_all(engine_dest, [table], checkfirst=True)
        metadata.create_all(engine_dest)
        logger.info(
            f"Table {schema_to_use+'.' if schema_to_use else ''}{target_table} created "
            f"in {target_db} with {len(columns)} columns"
        )

    except Exception as e:
        logger.error(f"Error in create_table_from_query: {e}")
        raise

    finally:
        # 4. Drop temporary view
        with engine_src.connect() as conn_src:
            try:
                drop_view(conn_src, engine_src.dialect.name, view_name)
                logger.info(f"Temporary view {view_name} dropped in {source_db}")
            except Exception as e:
                logger.warning(f"Could not drop temporary view {view_name}: {e}")


# if __name__ == "__main__":
#     create_table_from_query(
#         query_file="source/big_table_first.sql",
#         source_db="pruebas",
#         target_db="sqlserver1",
#         target_table="customers",
#     )