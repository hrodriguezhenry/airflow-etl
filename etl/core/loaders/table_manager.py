"""
Table management utilities for the ETL project.

This module provides helper functions to:
    - Create or replace database views in a dialect-safe way.
    - Drop views safely across supported engines.
    - Create a target table dynamically from the metadata of a SQL query,
      either by inspecting a temporary view (legacy approach) or directly
      from the SELECT metadata without creating objects in the source DB.

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
from sqlalchemy import Integer, BigInteger, Float, DateTime, Boolean, Numeric
from common.connections import get_engine
from common.utils import load_sql
from common.logger import logger
from common.type_mapping.generic import map_type

try:
    # Optional: improves MySQL metadata mapping
    from mysql.connector.constants import FieldType as MySQLFieldType
except Exception:  # pragma: no cover
    MySQLFieldType = None


def _sa_type_from_meta(base_type: str, length, precision, scale, dialect: str):
    """
    Best-effort mapping from a source base type to a SQLAlchemy type,
    using size/precision when available. This avoids the need for
    creating views in the source and aims for high fidelity.

    Args:
        base_type (str): Base/native type name (lowercase, e.g. 'varchar', 'int').
        length (int|None): Length for character/binary types.
        precision (int|None): Numeric precision.
        scale (int|None): Numeric scale.
        dialect (str): SQLAlchemy dialect name of the source (e.g. 'mssql', 'mysql').

    Returns:
        sqlalchemy.types.TypeEngine
    """
    bt = (base_type or "").lower()

    # Numeric
    if bt in {"decimal", "numeric", "money", "smallmoney"}:
        p = precision if precision is not None else 10
        s = scale if scale is not None else 2
        return Numeric(p, s)

    if bt in {"int", "integer", "smallint", "tinyint"}:
        return Integer()
    if bt == "bigint":
        return BigInteger()

    if bt in {"float", "real", "double", "double precision"}:
        return Float()

    # Boolean/bit
    if bt in {"bit", "boolean", "bool"}:
        return Boolean()

    # Date/Time
    if bt in {"date", "datetime", "datetime2", "smalldatetime", "time", "timestamp", "timestamptz"}:
        return DateTime()

    # Character and text-like
    if bt in {"varchar", "nvarchar", "char", "nchar", "bpchar", "varbinary"}:
        return String(length or 255)

    if bt in {"text", "ntext", "json", "jsonb", "xml", "uuid", "bytea", "blob"}:
        # Map to generic string; if exact BLOB/BYTEA needed, extend here.
        return String(length or 65535)

    # Fallback to generic mapping if available
    try:
        sa_type = map_type(bt, source=dialect, length=length, precision=precision, scale=scale)
        return sa_type
    except Exception:
        # Last resort: String
        return String(length or 255)


def _introspect_sqlserver(conn, query: str):
    """
    Use sp_describe_first_result_set to get accurate metadata from a SELECT.

    Returns list of dicts: name, base_type, length, precision, scale, nullable
    """
    escaped = query.replace("'", "''")
    sql = text(f"EXEC sp_describe_first_result_set @tsql = N'{escaped}'")
    rows = conn.execute(sql).mappings().all()
    cols = []
    for r in rows:
        # r keys include: name, system_type_name, is_nullable, max_length, precision, scale
        sys_type = (r.get("system_type_name") or "").lower()
        base = sys_type.split("(")[0].strip()
        max_len = r.get("max_length")
        prec = r.get("precision")
        scale = r.get("scale")

        # Convert NVARCHAR/NCHAR length from bytes to characters
        if base in {"nvarchar", "nchar"} and isinstance(max_len, int) and max_len > 0:
            max_len = max_len // 2

        # Handle (max) semantics → treat as text
        if "(max)" in sys_type:
            base = "text"
            max_len = None

        cols.append({
            "name": r.get("name"),
            "base_type": base,
            "length": max_len if (isinstance(max_len, int) and max_len > 0) else None,
            "precision": prec,
            "scale": scale,
            "nullable": bool(r.get("is_nullable")),
        })
    return cols


def _introspect_mysql(conn, query: str):
    """
    Use a LIMIT 0 subselect and DBAPI cursor.description for column metadata.
    Requires mysql-connector-python driver for precise type codes.
    """
    sql = f"SELECT * FROM ( {query} ) AS _t LIMIT 0"
    res = conn.exec_driver_sql(sql)
    cur = getattr(res, "cursor", None)
    desc = getattr(cur, "description", None)
    cols = []
    if not desc:
        return cols

    def mysql_type_name(type_code):
        if MySQLFieldType is None:
            return "varchar"
        # Map mysql-connector FieldType codes to base names
        mapping = {
            getattr(MySQLFieldType, "TINY", None): "tinyint",
            getattr(MySQLFieldType, "SHORT", None): "smallint",
            getattr(MySQLFieldType, "LONG", None): "int",
            getattr(MySQLFieldType, "LONGLONG", None): "bigint",
            getattr(MySQLFieldType, "FLOAT", None): "float",
            getattr(MySQLFieldType, "DOUBLE", None): "double",
            getattr(MySQLFieldType, "DECIMAL", None): "decimal",
            getattr(MySQLFieldType, "NEWDECIMAL", None): "decimal",
            getattr(MySQLFieldType, "DATE", None): "date",
            getattr(MySQLFieldType, "DATETIME", None): "datetime",
            getattr(MySQLFieldType, "TIMESTAMP", None): "timestamp",
            getattr(MySQLFieldType, "TIME", None): "time",
            getattr(MySQLFieldType, "VAR_STRING", None): "varchar",
            getattr(MySQLFieldType, "STRING", None): "varchar",
            getattr(MySQLFieldType, "BLOB", None): "text",
            getattr(MySQLFieldType, "BIT", None): "bit",
            getattr(MySQLFieldType, "JSON", None): "json",
        }
        return mapping.get(type_code, "varchar")

    # Each entry is a 7-item sequence: (name, type_code, display_size, internal_size, precision, scale, null_ok)
    for col in desc:
        name = col[0]
        type_code = col[1]
        display_size = col[2]
        internal_size = col[3]
        precision = col[4]
        scale = col[5]
        null_ok = bool(col[6]) if len(col) > 6 else True

        base = mysql_type_name(type_code)
        # Prefer internal_size, fallback to display_size
        length = internal_size or display_size

        cols.append({
            "name": name,
            "base_type": base,
            "length": int(length) if isinstance(length, int) and length > 0 else None,
            "precision": precision if isinstance(precision, int) else None,
            "scale": scale if isinstance(scale, int) else None,
            "nullable": null_ok,
        })

    return cols


def _introspect_postgresql(conn, query: str):
    """
    Best-effort introspection for PostgreSQL using LIMIT 0 and OID mapping.
    """
    sql = f"SELECT * FROM ( {query} ) AS t LIMIT 0"
    res = conn.exec_driver_sql(sql)
    cur = getattr(res, "cursor", None)
    desc = getattr(cur, "description", None)
    cols = []
    if not desc:
        return cols

    # Common OIDs mapping
    oid_map = {
        16: "bool",
        20: "bigint",
        21: "smallint",
        23: "integer",
        25: "text",
        700: "real",
        701: "double precision",
        1042: "char",
        1043: "varchar",
        1082: "date",
        1114: "timestamp",
        1184: "timestamptz",
        1700: "numeric",
        2950: "uuid",
    }
    for col in desc:
        name = col[0]
        type_code = col[1]
        display_size = col[2]
        internal_size = col[3]
        precision = col[4]
        scale = col[5]
        null_ok = bool(col[6]) if len(col) > 6 else True

        base = oid_map.get(type_code, "varchar")
        length = internal_size or display_size
        cols.append({
            "name": name,
            "base_type": base,
            "length": int(length) if isinstance(length, int) and length > 0 else None,
            "precision": precision if isinstance(precision, int) else None,
            "scale": scale if isinstance(scale, int) else None,
            "nullable": null_ok,
        })
    return cols


def _introspect_oracle(conn, query: str):
    """
    Basic Oracle introspection using WHERE 1=0 pattern.
    """
    sql = f"SELECT * FROM ( {query} ) t WHERE 1=0"
    res = conn.exec_driver_sql(sql)
    cur = getattr(res, "cursor", None)
    desc = getattr(cur, "description", None)
    cols = []
    if not desc:
        return cols
    for col in desc:
        name = col[0]
        type_code = col[1]
        display_size = col[2]
        internal_size = col[3]
        precision = col[4]
        scale = col[5]
        null_ok = bool(col[6]) if len(col) > 6 else True

        # cx_Oracle returns DBAPI description; lack of exact base type name here.
        base = "varchar"
        length = internal_size or display_size
        cols.append({
            "name": name,
            "base_type": base,
            "length": int(length) if isinstance(length, int) and length > 0 else None,
            "precision": precision if isinstance(precision, int) else None,
            "scale": scale if isinstance(scale, int) else None,
            "nullable": null_ok,
        })
    return cols


def _introspect_hana(conn, query: str):
    """
    Basic HANA introspection using WHERE 1=0 pattern.
    """
    sql = f"SELECT * FROM ( {query} ) t WHERE 1=0"
    res = conn.exec_driver_sql(sql)
    cur = getattr(res, "cursor", None)
    desc = getattr(cur, "description", None)
    cols = []
    if not desc:
        return cols
    for col in desc:
        name = col[0]
        display_size = col[2]
        internal_size = col[3]
        precision = col[4]
        scale = col[5]
        null_ok = bool(col[6]) if len(col) > 6 else True
        base = "varchar"
        length = internal_size or display_size
        cols.append({
            "name": name,
            "base_type": base,
            "length": int(length) if isinstance(length, int) and length > 0 else None,
            "precision": precision if isinstance(precision, int) else None,
            "scale": scale if isinstance(scale, int) else None,
            "nullable": null_ok,
        })
    return cols


def _introspect_query_columns(engine_src, query: str):
    """
    Inspect a SELECT statement and return columns metadata without creating a view.

    Returns list of dicts with: name, base_type, length, precision, scale, nullable
    """
    dialect = engine_src.dialect.name
    with engine_src.connect() as conn:
        if dialect == "mssql":
            return _introspect_sqlserver(conn, query)
        if dialect == "mysql":
            return _introspect_mysql(conn, query)
        if dialect == "postgresql":
            return _introspect_postgresql(conn, query)
        if dialect == "oracle":
            return _introspect_oracle(conn, query)
        if dialect == "hana":
            return _introspect_hana(conn, query)
        raise ValueError(f"Dialect '{dialect}' not supported for direct introspection")

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
        inspect_mode: str = "view",
    ):
    """
    Create a target table based on the metadata of a query.

    The function supports two inspection modes:
        - 'view'  (default): Creates a temporary view for schema inspection (legacy).
        - 'select': Inspects the SELECT directly without creating objects in source.

    Steps (select mode):
        1. Inspects column metadata from the SELECT using engine-specific methods
           (e.g., sp_describe_first_result_set for SQL Server or LIMIT 0 for others).
        2. Maps types and applies overrides.
        3. Creates the table in the target database.

    Steps (view mode):
        1. Creates a temporary view in the source database from the query.
        2. Inspects column metadata from the temporary view.
        3. Maps types and applies overrides.
        4. Creates the table in the target database.
        5. Drops the temporary view in the source database.

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
        columns = []

        if inspect_mode == "select":
            # Inspect directly from the SELECT (no source objects created)
            logger.info("Inspecting SELECT metadata without creating a view ...")
            col_meta = _introspect_query_columns(engine_src, query)

            for meta in col_meta:
                col_name = meta["name"]
                base_type = meta.get("base_type")
                length = meta.get("length")
                precision = meta.get("precision")
                scale = meta.get("scale")

                sa_type = _sa_type_from_meta(base_type, length, precision, scale, engine_src.dialect.name)

                # Apply overrides
                if overrides and col_name in overrides:
                    ov = overrides[col_name]
                    if "type" in ov:
                        sa_type = ov["type"]
                    elif "length" in ov and isinstance(sa_type, String):
                        sa_type = String(ov["length"])
                columns.append(Column(col_name, sa_type))

        else:
            # Legacy: create a temporary view and reflect columns
            with engine_src.connect() as conn_src:
                create_or_replace_view(conn_src, engine_src.dialect.name, view_name, query)
                logger.info(f"Temporary view {view_name} created in {engine_src.url.database}")

            insp = inspect(engine_src)
            col_meta = insp.get_columns(view_name, schema=engine_src.url.database)

            for meta in col_meta:
                col_name = meta["name"]
                col_type = meta["type"]
                length = getattr(col_type, "length", None)
                precision = getattr(col_type, "precision", None)
                scale = getattr(col_type, "scale", None)

                sa_type = _sa_type_from_meta(str(col_type), length, precision, scale, engine_src.dialect.name)

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

        # Create table in target
        metadata = MetaData()
        table = Table(target_table, metadata, *columns, schema=schema_to_use)
        metadata.drop_all(engine_dest, [table], checkfirst=True)
        metadata.create_all(engine_dest)
        logger.info(
            f"Table {schema_to_use+'.' if schema_to_use else ''}{target_table} created "
            f"in {engine_dest.url.database} with {len(columns)} columns"
        )

    except Exception as e:
        logger.error(f"Error in create_table_from_query: {e}")
        raise

    finally:
        # Drop temporary view only if it was created
        if inspect_mode != "select":
            with engine_src.connect() as conn_src:
                try:
                    drop_view(conn_src, engine_src.dialect.name, view_name)
                    logger.info(f"Temporary view {view_name} dropped in {engine_src.url.database}")
                except Exception as e:
                    logger.warning(f"Could not drop temporary view {view_name}: {e}")


# if __name__ == "__main__":
#     create_table_from_query(
#         query_file="source/big_table_first.sql",
#         source_db="pruebas",
#         target_db="sqlserver1",
#         target_table="customers",
#     )