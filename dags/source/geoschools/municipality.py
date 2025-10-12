from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.geoschools.municipality_incr import geoschools_municipality

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="source_geoschools_municipality",
    default_args=default_args,
    description="Carga de tabla municipality desde geoschools hacia DWH",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["geoschools"],
) as dag:

    run_etl = PythonOperator(
        task_id="source_geoschools_municipality",
        python_callable=geoschools_municipality
    )

    run_etl