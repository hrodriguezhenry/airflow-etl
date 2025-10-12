"""
File extraction utilities for the ETL project.

This module provides a helper function to extract data from CSV files
and return the content as a list of dictionaries, where each dictionary
represents a row (column names as keys).

Functions:
    - extract_from_csv(path):
      Read a CSV file and return its content as a list of dictionaries.

Example:
    from common.file_extractor import extract_from_csv

    rows = extract_from_csv("file/data.csv")
    print(rows[0])
    # {'id': 1, 'col1': 'Value A', 'col2': 'Value B'}
"""

import pandas as pd


def extract_from_csv(path):
    """
    Extract data from a CSV file as a list of dictionaries.

    Args:
        path (str | pathlib.Path):
            Path to the CSV file.

    Returns:
        list[dict]: List of rows, each row represented as a dictionary
        with column names as keys.

    Raises:
        FileNotFoundError: If the CSV file does not exist.
        pandas.errors.EmptyDataError: If the file is empty.
        pandas.errors.ParserError: If the file cannot be parsed as CSV.

    Example:
        >>> rows = extract_from_csv("file/data.csv")
        >>> print(rows[0])
        {'id': 1, 'col1': 'Value A', 'col2': 'Value B'}
    """
    return pd.read_csv(path).to_dict(orient="records")
