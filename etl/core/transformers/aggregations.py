import pandas as pd

def group_by_sum(rows, group_field, sum_field):
    df = pd.DataFrame(rows)
    grouped = df.groupby(group_field)[sum_field].sum().reset_index()
    return grouped.to_dict(orient="records")