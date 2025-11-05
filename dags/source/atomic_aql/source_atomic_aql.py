import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_aql.defect_incr import source_atomic_aql_defect
from etl.source.atomic_aql.military_incr import source_atomic_aql_military
from etl.source.atomic_aql.rmi_acceptation_level_incr import source_atomic_aql_rmi_acceptation_level
from etl.source.atomic_aql.rmi_box_acceptance_incr import source_atomic_aql_rmi_box_acceptance
from etl.source.atomic_aql.rmi_inspection_level_incr import source_atomic_aql_rmi_inspection_level
from etl.source.atomic_aql.rmi_revision_detail_batch_incr import source_atomic_aql_rmi_revision_detail_batch
from etl.source.atomic_aql.rmi_revision_detail_box_defect_incr import source_atomic_aql_rmi_revision_detail_box_defect
from etl.source.atomic_aql.rmi_revision_detail_box_incr import source_atomic_aql_rmi_revision_detail_box
from etl.source.atomic_aql.rmi_revision_detail_incr import source_atomic_aql_rmi_revision_detail
from etl.source.atomic_aql.rmi_revision_incr import source_atomic_aql_rmi_revision
from etl.source.atomic_aql.rmi_unit_revision_incr import source_atomic_aql_rmi_unit_revision

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "defect": source_atomic_aql_defect,
    "military": source_atomic_aql_military,
    "rmi_acceptation_level": source_atomic_aql_rmi_acceptation_level,
    "rmi_box_acceptance": source_atomic_aql_rmi_box_acceptance,
    "rmi_inspection_level": source_atomic_aql_rmi_inspection_level,
    "rmi_revision_detail_batch": source_atomic_aql_rmi_revision_detail_batch,
    "rmi_revision_detail_box_defect": source_atomic_aql_rmi_revision_detail_box_defect,
    "rmi_revision_detail_box": source_atomic_aql_rmi_revision_detail_box,
    "rmi_revision_detail": source_atomic_aql_rmi_revision_detail,
    "rmi_revision": source_atomic_aql_rmi_revision,
    "rmi_unit_revision": source_atomic_aql_rmi_unit_revision,
}

with DAG(
    dag_id="source_atomic_aql",
    default_args=default_args,
    description="Carga de ETLs de Atomic AQL hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_aql"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["defect"] >> tasks["military"] >> tasks["rmi_acceptation_level"] >> tasks["rmi_box_acceptance"]
    tasks["rmi_inspection_level"] >> tasks["rmi_revision_detail_batch"] >> tasks["rmi_revision_detail_box_defect"] >> tasks["rmi_revision_detail_box"]
    tasks["rmi_revision_detail"] >> tasks["rmi_revision"] >> tasks["rmi_unit_revision"]