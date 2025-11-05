import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.automate.belt_straps_reposition_incr import source_automate_belt_straps_reposition
from etl.source.automate.repositions_detail_incr import source_automate_repositions_detail
from etl.source.automate.standard_head_count_incr import source_automate_standard_head_count
from etl.source.automate.type_departure_incr import source_automate_type_departure

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "belt_straps_reposition": source_automate_belt_straps_reposition,
    "repositions_detail": source_automate_repositions_detail,
    "standard_head_count": source_automate_standard_head_count,
    "type_departure": source_automate_type_departure,
}

with DAG(
    dag_id="source_automate",
    default_args=default_args,
    description="Carga de ETLs de Automate hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["automate"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["belt_straps_reposition"] >> tasks["repositions_detail"] >> tasks["standard_head_count"] >> tasks["type_departure"]