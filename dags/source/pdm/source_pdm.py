from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.pdm.cf_circulation_form_incr import source_pdm_cf_circulation_form
from etl.source.pdm.cf_field_value_incr import source_pdm_cf_field_value
from etl.source.pdm.cf_input_field_incr import source_pdm_cf_input_field
from etl.source.pdm.size_catalog_incr import source_pdm_size_catalog

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "cf_input_field": source_pdm_cf_input_field,
    "cf_field_value": source_pdm_cf_field_value,
    "cf_circulation_form": source_pdm_cf_circulation_form,
    "size_catalog": source_pdm_size_catalog,
}

with DAG(
    dag_id="source_pdm",
    default_args=default_args,
    description="Carga de ETLs de PDM hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["pdm"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["cf_input_field"] >> tasks["cf_field_value"] >> tasks["cf_circulation_form"] >> tasks["size_catalog"]
