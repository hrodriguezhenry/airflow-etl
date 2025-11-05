import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic.line_incr import source_atomic_line
from etl.source.atomic.stage_incr import source_atomic_stage
from etl.source.atomic.stage_system_inspection_incr import source_atomic_stage_system_inspection
from etl.source.atomic.stage_system_production_incr import source_atomic_stage_system_production
from etl.source.atomic.station_system_incr import source_atomic_station_system
from etl.source.atomic.style_layer_incr import source_atomic_style_layer

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "line": source_atomic_line,
    "stage": source_atomic_stage,
    "stage_system_inspection": source_atomic_stage_system_inspection,
    "stage_system_production": source_atomic_stage_system_production,
    "station_system": source_atomic_station_system,
    "style_layer": source_atomic_style_layer,
}

with DAG(
    dag_id="source_atomic",
    default_args=default_args,
    description="Carga de ETLs de Atomic hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=callable_,
        )
        for name, callable_ in ETL_TASKS.items()
    }

    tasks["line"] >> tasks["stage"] >> tasks["stage_system_inspection"] >> tasks["stage_system_production"]
    tasks["station_system"] >> tasks["style_layer"]