"""
Type mapping for Oracle to SQLAlchemy types.

This module provides a dictionary ``ORACLE_TYPE_MAP`` that maps
native Oracle data types to their equivalent SQLAlchemy types.

It is used by the generic type mapping utilities
(`common.type_mapping.generic.map_type`) to ensure consistent
type handling across different database engines.

Example:
    from common.type_mapping.oracle import ORACLE_TYPE_MAP
    from sqlalchemy import Numeric

    assert ORACLE_TYPE_MAP["NUMBER"] == Numeric
"""

from sqlalchemy import Float, DateTime, String, Numeric

ORACLE_TYPE_MAP = {
    "NUMBER": Numeric,
    "FLOAT": Float,
    "BINARY_FLOAT": Float,
    "DATE": DateTime,
    "TIMESTAMP": DateTime,
    "CHAR": String,
    "NCHAR": String,
    "VARCHAR": String,
    "VARCHAR2": String,
    "NVARCHAR2": String,
    "CLOB": String,
}

"""
Dictionary mapping Oracle native types to SQLAlchemy types.

Keys:
    str: Oracle type in uppercase.
Values:
    sqlalchemy.types.TypeEngine: Corresponding SQLAlchemy type.

Notes:
    - ``NUMBER`` is mapped to ``Numeric`` (precision/scale handled separately).
    - ``DATE`` and ``TIMESTAMP`` are mapped to ``DateTime``.
    - Character-based types (CHAR, NCHAR, VARCHAR, VARCHAR2, NVARCHAR2, CLOB)
      are mapped to ``String``.
    - ``FLOAT`` and ``BINARY_FLOAT`` are mapped to ``Float``.
"""