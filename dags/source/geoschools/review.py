from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.geoschools.review_incr import geoschools_review

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="source_geoschools_review",
    default_args=default_args,
    description="Carga de tabla review desde geoschools hacia DWH",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["geoschools"],
) as dag:

    run_etl = PythonOperator(
        task_id="source_geoschools_review",
        python_callable=geoschools_review
    )

    run_etl