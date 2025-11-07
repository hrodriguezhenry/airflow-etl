from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.nesting_orders.batches_incr import source_source_nesting_orders_batches
from etl.source.nesting_orders.jobs_incr import source_source_nesting_orders_jobs
from etl.source.nesting_orders.lay_shapes_incr import source_source_nesting_orders_lay_shapes
from etl.source.nesting_orders.layouts_incr import source_source_nesting_orders_layouts
from etl.source.nesting_orders.libraries_incr import source_source_nesting_orders_libraries
from etl.source.nesting_orders.material_codes_incr import source_source_nesting_orders_material_codes
from etl.source.nesting_orders.materials_incr import source_source_nesting_orders_materials
from etl.source.nesting_orders.sessions_incr import source_source_nesting_orders_sessions
from etl.source.nesting_orders.shapes_incr import source_source_nesting_orders_shapes

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "libraries": source_source_nesting_orders_libraries,
    "material_codes": source_source_nesting_orders_material_codes,
    "materials": source_source_nesting_orders_materials,
    "shapes": source_source_nesting_orders_shapes,
    "lay_shapes": source_source_nesting_orders_lay_shapes,
    "layouts": source_source_nesting_orders_layouts,
    "jobs": source_source_nesting_orders_jobs,
    "batches": source_source_nesting_orders_batches,
    "sessions": source_source_nesting_orders_sessions,
}

with DAG(
    dag_id="source_nesting_orders",
    default_args=default_args,
    description="Carga de ETLs de Nesting Orders hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["nesting_orders"],
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