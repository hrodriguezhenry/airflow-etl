"""
Type mapping for SAP HANA to SQLAlchemy types.

This module provides a dictionary ``HANA_TYPE_MAP`` that maps
native SAP HANA data types to their equivalent SQLAlchemy types.

It is used by the generic type mapping utilities
(`common.type_mapping.generic.map_type`) to ensure consistent
type handling across different database engines.

Example:
    from common.type_mapping.hana import HANA_TYPE_MAP
    from sqlalchemy import String

    assert HANA_TYPE_MAP["VARCHAR"] == String
"""

from sqlalchemy import Integer, BigInteger, Float, DateTime, String, Numeric

HANA_TYPE_MAP = {
    "INTEGER": Integer,
    "TINYINT": Integer,
    "SMALLINT": Integer,
    "BIGINT": BigInteger,
    "DECIMAL": Numeric,
    "REAL": Float,
    "DOUBLE": Float,
    "DATE": DateTime,
    "TIME": DateTime,
    "SECONDDATE": DateTime,
    "VARCHAR": String,
    "NVARCHAR": String,
    "TEXT": String,
}

"""
Dictionary mapping SAP HANA native types to SQLAlchemy types.

Keys:
    str: SAP HANA type in uppercase.
Values:
    sqlalchemy.types.TypeEngine: Corresponding SQLAlchemy type.

Notes:
    - DATE, TIME and SECONDDATE are mapped to SQLAlchemy ``DateTime``.
    - All string-based types (VARCHAR, NVARCHAR, TEXT) are mapped to ``String``.
    - DECIMAL is mapped to ``Numeric`` (precision/scale handled separately).
"""