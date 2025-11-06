import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.proaktiv.vendors_incr import source_proaktiv_vendors
from etl.source.proaktiv.vendors_information_incr import source_proaktiv_vendors_information
from etl.source.proaktiv.vias_incr import source_proaktiv_vias
from etl.source.proaktiv.warehouses_incr import source_proaktiv_warehouses
from etl.source.proaktiv.weights_specific_expenses_incr import source_proaktiv_weights_specific_expenses

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "vendors": source_proaktiv_vendors,
    "vendors_information": source_proaktiv_vendors_information,
    "vias": source_proaktiv_vias,
    "warehouses": source_proaktiv_warehouses,
    "weights_specific_expenses": source_proaktiv_weights_specific_expenses,
}

with DAG(
    dag_id="source_proaktiv_part_2",
    default_args=default_args,
    description="Carga de ETLs de Proaktiv hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["proaktiv"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["vendors"] >> tasks["vendors_information"] >> tasks["vias"] >> tasks["warehouses"]
    tasks["weights_specific_expenses"]