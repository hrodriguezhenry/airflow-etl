"""
API extraction utilities for the ETL project.

This module provides a helper function to extract data from REST APIs
using HTTP GET requests. The response is automatically validated and
parsed into JSON format.

Functions:
    - extract_from_api(url, headers=None, params=None):
      Perform a GET request and return the parsed JSON response.

Example:
    from common.api_extractor import extract_from_api

    url = "https://jsonplaceholder.typicode.com/posts"
    data = extract_from_api(url, params={"userId": 1})
    print(data[0]["title"])
"""

import requests


def extract_from_api(url, headers=None, params=None):
    """
    Extract data from a REST API using HTTP GET.

    Args:
        url (str):
            Full API endpoint URL.
        headers (dict, optional):
            HTTP headers to include in the request (e.g., auth tokens).
        params (dict, optional):
            Query parameters to include in the request.

    Returns:
        dict | list: Parsed JSON response from the API.

    Raises:
        requests.exceptions.HTTPError: If the response contains an HTTP error.
        requests.exceptions.RequestException: For network-related errors.

    Example:
        >>> url = "https://jsonplaceholder.typicode.com/posts"
        >>> data = extract_from_api(url, params={"userId": 1})
        >>> print(data[0]["id"])
        1
    """
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()
