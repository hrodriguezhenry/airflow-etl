"""
Type mapping for MySQL to SQLAlchemy types.

This module provides a dictionary ``MYSQL_TYPE_MAP`` that maps
native MySQL data types to their equivalent SQLAlchemy types.

It is used by the generic type mapping utilities
(`common.type_mapping.generic.map_type`) to ensure consistent
type handling across different database engines.

Example:
    from common.type_mapping.mysql import MYSQL_TYPE_MAP
    from sqlalchemy import Boolean

    assert MYSQL_TYPE_MAP["TINYINT"] == Boolean
"""

from sqlalchemy import Integer, BigInteger, Float, DateTime, String, Boolean, Numeric

MYSQL_TYPE_MAP = {
    "TINYINT": Boolean,
    "SMALLINT": Integer,
    "INT": Integer,
    "BIGINT": BigInteger,
    "FLOAT": Float,
    "DOUBLE": Float,
    "DECIMAL": Numeric,
    "NUMERIC": Numeric,
    "DATE": DateTime,
    "DATETIME": DateTime,
    "TIMESTAMP": DateTime,
    "VARCHAR": String,
    "TEXT": String,
}

"""
Dictionary mapping MySQL native types to SQLAlchemy types.

Keys:
    str: MySQL type in uppercase.
Values:
    sqlalchemy.types.TypeEngine: Corresponding SQLAlchemy type.

Notes:
    - ``TINYINT`` is mapped to ``Boolean`` (common convention for MySQL).
    - ``DATE``, ``DATETIME`` and ``TIMESTAMP`` are mapped to ``DateTime``.
    - ``DECIMAL`` and ``NUMERIC`` are mapped to ``Numeric`` 
      (precision/scale handled separately).
    - String-based types (VARCHAR, TEXT) are mapped to ``String``.
"""