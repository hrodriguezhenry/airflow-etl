import requests

def load_to_api(url, rows, headers=None):
    for row in rows:
        r = requests.post(url, json=row, headers=headers)
        r.raise_for_status()