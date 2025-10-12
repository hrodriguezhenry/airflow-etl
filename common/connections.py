"""
Database connection utilities for the ETL project.

This module loads database connection settings from
``config/db_connections.yaml`` and provides a function
to create SQLAlchemy engines for multiple supported databases.

Supported drivers:
    - MySQL (mysqlconnector)
    - SQL Server (ODBC Driver 17)
    - PostgreSQL (psycopg2)
    - Oracle (oracledb)
    - SAP HANA

Example:
    from common.connections import get_engine

    engine = get_engine("db_alias")
    with engine.connect() as conn:
        result = conn.execute("SELECT 1")
        print(result.scalar())  # 1
"""

import yaml
from pathlib import Path
from sqlalchemy import create_engine
from .logger import logger

def _load_config():
    """
    Load database connection configuration from
    ``config/db_connections.yaml``.

    Returns:
        dict: Parsed YAML configuration with database aliases as keys.

    Raises:
        FileNotFoundError: If ``db_connections.yaml`` does not exist.
        yaml.YAMLError: If the file has invalid YAML syntax.
    """
    config_path = Path(__file__).resolve().parent.parent / "config" / "db_connections.yaml"
    with open(config_path, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)

CONFIG = _load_config()

def get_engine(db_key: str):
    """
    Create a SQLAlchemy engine from a database alias defined
    in ``db_connections.yaml``.

    Args:
        db_key (str): Alias of the database connection
            (e.g., "database").

    Returns:
        sqlalchemy.engine.Engine: A SQLAlchemy engine connected
        to the target database.

    Raises:
        ValueError: If the driver is not supported.
        KeyError: If ``db_key`` is not defined in the YAML config.
        Exception: Any other error from SQLAlchemy when creating the engine.

    Example:
        >>> engine = get_engine("db_alias")
        >>> with engine.connect() as conn:
        ...     result = conn.execute("SELECT 1")
        ...     print(result.scalar())
        1
    """
    if db_key not in CONFIG:
        logger.error(f"Database '{db_key}' not defined in db_connections.yaml")
        raise KeyError(f"Database '{db_key}' not defined in db_connections.yaml")

    db_conf = CONFIG[db_key]
    driver = db_conf["driver"].lower()

    try:
        if driver == "mysql":
            url = (
                f"mysql+mysqlconnector://{db_conf['user']}:{db_conf['password']}"
                f"@{db_conf['host']}:{db_conf['port']}/{db_conf['database']}"
            )

        elif driver == "sqlserver":
            url = (
                f"mssql+pyodbc://{db_conf['user']}:{db_conf['password']}"
                f"@{db_conf['host']},{db_conf['port']}/{db_conf['database']}"
                "?driver=ODBC+Driver+17+for+SQL+Server"
            )

        elif driver == "postgres":
            url = (
                f"postgresql+psycopg2://{db_conf['user']}:{db_conf['password']}"
                f"@{db_conf['host']}:{db_conf['port']}/{db_conf['database']}"
            )

        elif driver == "oracle":
            url = (
                f"oracle+oracledb://{db_conf['user']}:{db_conf['password']}"
                f"@{db_conf['host']}:{db_conf['port']}/?service_name={db_conf['database']}"
            )

        elif driver == "hana":
            url = (
                f"hana://{db_conf['user']}:{db_conf['password']}"
                f"@{db_conf['host']}:{db_conf['port']}"
            )

        else:
            logger.error(f"Unsupported driver: {driver}")
            raise ValueError(f"Unsupported driver: {driver}")

        engine = create_engine(url, future=True)
        logger.info(f"Connection successfully created for '{db_key}' ({driver})")
        return engine

    except Exception as e:
        logger.error(f"Error creating engine for '{db_key}': {e}")
        raise