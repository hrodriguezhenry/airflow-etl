import os
from datetime import datetime, timedelta

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

    inspection_bundle = PythonOperator(
        task_id="inspection_bundle",
        python_callable=source_atomic_qis_inspection_bundle
    )

    inspection_defect = PythonOperator(
        task_id="inspection_defect",
        python_callable=source_atomic_qis_inspection_defect
    )

    inspection_distribution_defect = PythonOperator(
        task_id="inspection_distribution_defect",
        python_callable=source_atomic_qis_inspection_distribution_defect
    )

    inspection_distribution = PythonOperator(
        task_id="inspection_distribution",
        python_callable=source_atomic_qis_inspection_distribution
    )

    inspection_group_defect = PythonOperator(
        task_id="inspection_group_defect",
        python_callable=source_atomic_qis_inspection_group_defect
    )

    inspection_group_mark_defect_detail = PythonOperator(
        task_id="inspection_group_mark_defect_detail",
        python_callable=source_atomic_qis_inspection_group_mark_defect_detail
    )

    inspection_group_mark_defect = PythonOperator(
        task_id="inspection_group_mark_defect",
        python_callable=source_atomic_qis_inspection_group_mark_defect
    )

    inspection_revision = PythonOperator(
        task_id="inspection_revision",
        python_callable=source_atomic_qis_inspection_revision
    )

    inspection_revision_repair = PythonOperator(
        task_id="inspection_revision_repair",
        python_callable=source_atomic_qis_inspection_revision_repair
    )

    inspection_stage = PythonOperator(
        task_id="inspection_stage",
        python_callable=source_atomic_qis_inspection_stage
    )

    inspection_standard = PythonOperator(
        task_id="inspection_standard",
        python_callable=source_atomic_qis_inspection_standard
    )

    inspection_station = PythonOperator(
        task_id="inspection_station",
        python_callable=source_atomic_qis_inspection_station
    )

    inspection_bundle >> inspection_defect >> inspection_distribution_defect >> inspection_distribution
    inspection_group_defect >> inspection_group_mark_defect_detail >> inspection_group_mark_defect >> inspection_revision
    inspection_revision_repair >> inspection_stage >> inspection_standard >> inspection_station