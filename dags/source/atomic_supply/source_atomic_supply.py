import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_supply.material_incr import source_atomic_supply_material
from etl.source.atomic_supply.process_formula_incr import source_atomic_supply_process_formula
from etl.source.atomic_supply.process_group_incr import source_atomic_supply_process_group
from etl.source.atomic_supply.process_incr import source_atomic_supply_process
from etl.source.atomic_supply.process_repair_detail_incr import source_atomic_supply_process_repair_detail
from etl.source.atomic_supply.process_repair_incr import source_atomic_supply_process_repair

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "material": source_atomic_supply_material,
    "process_formula": source_atomic_supply_process_formula,
    "process_group": source_atomic_supply_process_group,
    "process": source_atomic_supply_process,
    "process_repair_detail": source_atomic_supply_process_repair_detail,
    "process_repair": source_atomic_supply_process_repair,
}

with DAG(
    dag_id="source_atomic_supply",
    default_args=default_args,
    description="Carga de ETLs de Atomic Supply hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_supply"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["material"] >> tasks["process_formula"] >> tasks["process_group"] >> tasks["process"]
    tasks["process_repair_detail"] >> tasks["process_repair"]