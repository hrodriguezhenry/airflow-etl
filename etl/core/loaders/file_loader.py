import pandas as pd

def load_to_csv(path, rows):
    df = pd.DataFrame(rows)
    df.to_csv(path, index=False)