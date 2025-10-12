"""
Centralized logging configuration for the ETL project.

This module configures a global logger named ``ETL`` that outputs logs to both
the console and a rotating log file. The log file rotates daily at midnight
and retains logs for the last 7 days.

Usage:
    from common.logger import logger

    logger.info("ETL job started")
    logger.warning("Row count mismatch detected")
    logger.error("Database connection failed")

Log files are stored under:
    ./logs/etl/etl.log
"""

import logging
from logging.handlers import TimedRotatingFileHandler
from pathlib import Path

# Directory for log files: ./logs/etl
LOG_DIR = Path(__file__).resolve().parent.parent / "logs" / "etl"
LOG_DIR.mkdir(parents=True, exist_ok=True)

# Main log file (rotates daily at midnight, keeps 7 backups)
LOG_FILE = LOG_DIR / "etl.log"

# Rotating file handler
handler = TimedRotatingFileHandler(
    LOG_FILE, when="midnight", interval=1, backupCount=7, encoding="utf-8"
)
"""
Timed rotating file handler:
    - Rotates the log file every midnight.
    - Keeps the last 7 log files.
    - Writes logs in UTF-8 encoding.
"""

# Logging configuration
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.StreamHandler(),  # Console
        handler                   # File
    ]
)

# Global logger for the ETL project
logger = logging.getLogger("ETL")
"""
Global ETL logger instance.

Use this logger throughout the project instead of creating new ones.
"""