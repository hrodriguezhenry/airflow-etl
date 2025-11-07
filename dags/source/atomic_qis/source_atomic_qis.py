from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_qis.inspection_bundle_incr import source_atomic_qis_inspection_bundle
from etl.source.atomic_qis.inspection_defect_incr import source_atomic_qis_inspection_defect
from etl.source.atomic_qis.inspection_distribution_defect_incr import source_atomic_qis_inspection_distribution_defect
from etl.source.atomic_qis.inspection_distribution_incr import source_atomic_qis_inspection_distribution
from etl.source.atomic_qis.inspection_group_defect_incr import source_atomic_qis_inspection_group_defect
from etl.source.atomic_qis.inspection_group_mark_defect_detail_incr import source_atomic_qis_inspection_group_mark_defect_detail
from etl.source.atomic_qis.inspection_group_mark_defect_incr import source_atomic_qis_inspection_group_mark_defect
from etl.source.atomic_qis.inspection_revision_incr import source_atomic_qis_inspection_revision
from etl.source.atomic_qis.inspection_revision_repair_incr import source_atomic_qis_inspection_revision_repair
from etl.source.atomic_qis.inspection_stage_incr import source_atomic_qis_inspection_stage
from etl.source.atomic_qis.inspection_standard_incr import source_atomic_qis_inspection_standard
from etl.source.atomic_qis.inspection_station_incr import source_atomic_qis_inspection_station

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "inspection_bundle": source_atomic_qis_inspection_bundle,
    "inspection_defect": source_atomic_qis_inspection_defect,
    "inspection_distribution_defect": source_atomic_qis_inspection_distribution_defect,
    "inspection_distribution": source_atomic_qis_inspection_distribution,
    "inspection_group_defect": source_atomic_qis_inspection_group_defect,
    "inspection_group_mark_defect_detail": source_atomic_qis_inspection_group_mark_defect_detail,
    "inspection_group_mark_defect": source_atomic_qis_inspection_group_mark_defect,
    "inspection_revision": source_atomic_qis_inspection_revision,
    "inspection_revision_repair": source_atomic_qis_inspection_revision_repair,
    "inspection_stage": source_atomic_qis_inspection_stage,
    "inspection_standard": source_atomic_qis_inspection_standard,
    "inspection_station": source_atomic_qis_inspection_station,
}

with DAG(
    dag_id="source_atomic_qis",
    default_args=default_args,
    description="Carga de ETLs de Atomic QIS hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_qis"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["inspection_bundle"] >> tasks["inspection_defect"] >> tasks["inspection_distribution_defect"] >> tasks["inspection_distribution"]
    tasks["inspection_group_defect"] >> tasks["inspection_group_mark_defect_detail"] >> tasks["inspection_group_mark_defect"] >> tasks["inspection_revision"]
    tasks["inspection_revision_repair"] >> tasks["inspection_stage"] >> tasks["inspection_standard"] >> tasks["inspection_station"]