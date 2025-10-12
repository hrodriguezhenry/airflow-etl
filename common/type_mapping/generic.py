"""
Generic type mapping utilities for the ETL project.

This module provides helper functions to normalize database types
(from MySQL, SQL Server, Oracle, SAP HANA, REST sources, etc.) into
consistent SQLAlchemy types.

It is used when creating tables dynamically across multiple database
engines to ensure portability and consistency of column definitions.

Functions:
    - normalize_db_type(db_type): Normalize native type to a string.
    - map_type(db_type, source, length=None, precision=None, scale=None):
      Map native type into a SQLAlchemy type object.

Example:
    from common.type_mapping.generic import map_type

    sa_type = map_type("VARCHAR", source="mysql", length=100)
    print(sa_type)  # VARCHAR(100)
"""

from sqlalchemy import String, Numeric
from sqlalchemy.sql.type_api import TypeEngine
from .mysql import MYSQL_TYPE_MAP
from .sqlserver import SQLSERVER_TYPE_MAP
from .oracle import ORACLE_TYPE_MAP
from .hana import HANA_TYPE_MAP
from .rest import REST_TYPE_MAP

# Mapping dictionaries from each supported source
SOURCE_MAPS = {
    "mysql": MYSQL_TYPE_MAP,
    "sqlserver": SQLSERVER_TYPE_MAP,
    "oracle": ORACLE_TYPE_MAP,
    "sapb1": HANA_TYPE_MAP,
    "rest": REST_TYPE_MAP,
}


def normalize_db_type(db_type):
    """
    Normalize a database type into an uppercase string.

    Args:
        db_type (Union[str, sqlalchemy.sql.type_api.TypeEngine, int]):
            Database type, which may come as:
            - A SQLAlchemy TypeEngine subclass (e.g. String, Numeric).
            - A string (e.g. "varchar", "int").
            - A numeric code or other type.

    Returns:
        str: Normalized database type in uppercase.

    Example:
        >>> normalize_db_type("varchar")
        'VARCHAR'
        >>> normalize_db_type(String())
        'STRING'
    """
    if isinstance(db_type, TypeEngine):
        return db_type.__class__.__name__.upper()
    if isinstance(db_type, str):
        return db_type.upper()
    return str(db_type).upper()


def map_type(db_type, source, length=None, precision=None, scale=None):
    """
    Map a native database type to a SQLAlchemy type.

    Args:
        db_type (Union[str, sqlalchemy.sql.type_api.TypeEngine, int]):
            The original database type to be mapped.
        source (str): Source system alias (e.g., "mysql", "sqlserver",
            "oracle", "saphana", "rest").
        length (int, optional): Length of the type (for string types).
        precision (int, optional): Precision (for numeric types).
        scale (int, optional): Scale (for numeric types).

    Returns:
        sqlalchemy.types.TypeEngine: Corresponding SQLAlchemy type.

    Example:
        >>> map_type("varchar", source="mysql", length=50)
        VARCHAR(50)

        >>> map_type("decimal", source="sqlserver", precision=12, scale=4)
        NUMERIC(12, 4)
    """
    norm_type = normalize_db_type(db_type)
    type_map = SOURCE_MAPS.get(source, {})
    sa_type = type_map.get(norm_type, String)

    if sa_type == String:
        return String(length or 255)
    if sa_type == Numeric:
        return Numeric(precision or 10, scale or 2)

    return sa_type()