from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.nesting_bills.batches_incr import source_nesting_bills_batches
from etl.source.nesting_bills.jobs_incr import source_nesting_bills_jobs
from etl.source.nesting_bills.lay_shapes_incr import source_nesting_bills_lay_shapes
from etl.source.nesting_bills.layouts_incr import source_nesting_bills_layouts
from etl.source.nesting_bills.libraries_incr import source_nesting_bills_libraries
from etl.source.nesting_bills.material_codes_incr import source_nesting_bills_material_codes
from etl.source.nesting_bills.materials_incr import source_nesting_bills_materials
from etl.source.nesting_bills.sessions_incr import source_nesting_bills_sessions
from etl.source.nesting_bills.shapes_incr import source_nesting_bills_shapes

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "libraries": source_nesting_bills_libraries,
    "material_codes": source_nesting_bills_material_codes,
    "materials": source_nesting_bills_materials,
    "shapes": source_nesting_bills_shapes,
    "lay_shapes": source_nesting_bills_lay_shapes,
    "layouts": source_nesting_bills_layouts,
    "jobs": source_nesting_bills_jobs,
    "batches": source_nesting_bills_batches,
    "sessions": source_nesting_bills_sessions,
}

with DAG(
    dag_id="source_nesting_bills",
    default_args=default_args,
    description="Carga de ETLs de Nesting Bills hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["nesting_bills"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["libraries"] >> tasks["material_codes"] >> tasks["materials"] >> tasks["shapes"]
    tasks["lay_shapes"] >> tasks["layouts"] >> tasks["jobs"] >> tasks["batches"]
    tasks["sessions"]