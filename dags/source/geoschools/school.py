from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.geoschools.school_incr import geoschools_school

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="source_geoschools_school",
    default_args=default_args,
    description="Carga de tabla school desde geoschools hacia DWH",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["geoschools"],
) as dag:

    run_etl = PythonOperator(
        task_id="source_geoschools_school",
        python_callable=geoschools_school
    )

    run_etl