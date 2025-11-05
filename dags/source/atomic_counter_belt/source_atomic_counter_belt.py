import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_counter_belt.configuration_incr import source_atomic_counter_belt_configuration
from etl.source.atomic_counter_belt.configuration_laminated_incr import source_atomic_counter_belt_configuration_laminated
from etl.source.atomic_counter_belt.configuration_ref_incr import source_atomic_counter_belt_configuration_ref

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "configuration": source_atomic_counter_belt_configuration,
    "configuration_laminated": source_atomic_counter_belt_configuration_laminated,
    "configuration_ref": source_atomic_counter_belt_configuration_ref,
}

with DAG(
    dag_id="source_atomic_counter_belt",
    default_args=default_args,
    description="Carga de ETLs de Atomic Counter Belt hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_counter_belt"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["configuration"] >> tasks["configuration_laminated"] >> tasks["configuration_ref"]