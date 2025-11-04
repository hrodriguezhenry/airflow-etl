import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.accesorios.weeks_incr import source_accesorios_weeks

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="source_accesorios",
    default_args=default_args,
    description="Carga de ETls de Accesorios hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["accesorios"],
) as dag:

    weeks = PythonOperator(
        task_id="weeks",
        python_callable=source_accesorios_weeks
    )

    weeks