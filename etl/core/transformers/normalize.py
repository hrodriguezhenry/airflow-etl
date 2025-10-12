def normalize_strings(row, fields):
    for f in fields:
        if row.get(f):
            row[f] = row[f].strip().upper()
    return row

def clean_emails(row):
    if row.get("email"):
        row["email"] = row["email"].lower().strip()
    return row