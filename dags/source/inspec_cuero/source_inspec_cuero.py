from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.inspec_cuero.decisions_incr import source_inspec_cuero_decisions
from etl.source.inspec_cuero.headers_incr import source_inspec_cuero_headers
from etl.source.inspec_cuero.rejection_header_incr import source_inspec_cuero_rejection_header
from etl.source.inspec_cuero.rejections_incr import source_inspec_cuero_rejections

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "headers": source_inspec_cuero_headers,
    "decisions": source_inspec_cuero_decisions,
    "rejection_header": source_inspec_cuero_rejection_header,
    "rejections": source_inspec_cuero_rejections,
}

with DAG(
    dag_id="source_inspec_cuero",
    default_args=default_args,
    description="Carga de ETLs de Inspec Cuero hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["inspec_cuero"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["headers"] >> tasks["decisions"] >> tasks["rejection_header"] >> tasks["rejections"]