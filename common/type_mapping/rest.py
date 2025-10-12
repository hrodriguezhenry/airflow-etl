"""
Type mapping for REST/JSON sources to SQLAlchemy types.

This module provides a dictionary ``REST_TYPE_MAP`` that maps
generic REST/JSON field types to their equivalent SQLAlchemy types.

It is used by the generic type mapping utilities
(`common.type_mapping.generic.map_type`) to ensure consistent
type handling across structured and semi-structured sources.

Example:
    from common.type_mapping.rest import REST_TYPE_MAP
    from sqlalchemy import String

    assert REST_TYPE_MAP["string"] == String
"""

from sqlalchemy import Integer, BigInteger, Float, DateTime, String, Boolean, Numeric

REST_TYPE_MAP = {
    "string": String,
    "integer": Integer,
    "long": BigInteger,
    "number": Float,
    "decimal": Numeric,
    "boolean": Boolean,
    "date": DateTime,
    "datetime": DateTime,
}

"""
Dictionary mapping REST/JSON field types to SQLAlchemy types.

Keys:
    str: REST/JSON type in lowercase.
Values:
    sqlalchemy.types.TypeEngine: Corresponding SQLAlchemy type.

Notes:
    - ``string`` is mapped to ``String``.
    - ``integer`` is mapped to ``Integer``.
    - ``long`` is mapped to ``BigInteger``.
    - ``number`` is mapped to ``Float``.
    - ``decimal`` is mapped to ``Numeric`` (precision/scale handled separately).
    - ``boolean`` is mapped to ``Boolean``.
    - ``date`` and ``datetime`` are mapped to ``DateTime``.
"""