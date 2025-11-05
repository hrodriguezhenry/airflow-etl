import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.fast_react.weekly_planning_incr import source_fast_react_weekly_planning
from etl.source.fast_react.weekly_planning_old_incr import source_fast_react_weekly_planning_old

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "weekly_planning": source_fast_react_weekly_planning,
    "weekly_planning_old": source_fast_react_weekly_planning_old,
}

with DAG(
    dag_id="source_fast_react",
    default_args=default_args,
    description="Carga de ETLs de Fast React hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["fast_react"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["weekly_planning"] >> tasks["weekly_planning_old"]