from pathlib import Path

def load_sql(path: str) -> str:
    """
    Load a SQL file from the `/queries` folder.

    Args:
        path (str): Relative path of the SQL file within the `queries` folder.
            Example: "source/database/table.sql".

    Returns:
        str: Full SQL file content.

    Raises:
        FileNotFoundError: If the file does not exist at the given path.
        UnicodeDecodeError: If an error occurs when reading the file with UTF-8.

    Example:
        >>> sql = load_sql("source/database/table.sql")
        >>> print(sql[:50])
        "SELECT column1, column2, column3 FROM table ..."
    """
    base_path = Path(__file__).resolve().parent.parent / "queries"
    with open(base_path / path, "r", encoding="utf-8") as f:
        return f.read()
