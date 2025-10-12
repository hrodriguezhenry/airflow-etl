"""
Type mapping for SQL Server to SQLAlchemy types.

This module provides a dictionary ``SQLSERVER_TYPE_MAP`` that maps
native SQL Server data types to their equivalent SQLAlchemy types.

It is used by the generic type mapping utilities
(`common.type_mapping.generic.map_type`) to ensure consistent
type handling across different database engines.

Example:
    from common.type_mapping.sqlserver import SQLSERVER_TYPE_MAP
    from sqlalchemy import Integer

    assert SQLSERVER_TYPE_MAP["int"] == Integer
"""

from sqlalchemy import Integer, BigInteger, Float, DateTime, String, Boolean, Numeric

SQLSERVER_TYPE_MAP = {
    "int": Integer,
    "bigint": BigInteger,
    "smallint": Integer,
    "tinyint": Integer,
    "bit": Boolean,
    "decimal": Numeric,
    "numeric": Numeric,
    "money": Numeric,
    "float": Float,
    "real": Float,
    "date": DateTime,
    "datetime": DateTime,
    "smalldatetime": DateTime,
    "nvarchar": String,
    "varchar": String,
    "char": String,
    "nchar": String,
    "text": String,
}

"""
Dictionary mapping SQL Server native types to SQLAlchemy types.

Keys:
    str: SQL Server type in lowercase.
Values:
    sqlalchemy.types.TypeEngine: Corresponding SQLAlchemy type.

Notes:
    - ``int``, ``smallint``, ``tinyint`` are mapped to ``Integer``.
    - ``bigint`` is mapped to ``BigInteger``.
    - ``bit`` is mapped to ``Boolean``.
    - ``decimal``, ``numeric``, ``money`` are mapped to ``Numeric`` 
      (precision/scale handled separately).
    - ``float`` and ``real`` are mapped to ``Float``.
    - ``date``, ``datetime``, ``smalldatetime`` are mapped to ``DateTime``.
    - Character-based types (nvarchar, varchar, char, nchar, text)
      are mapped to ``String``.
"""