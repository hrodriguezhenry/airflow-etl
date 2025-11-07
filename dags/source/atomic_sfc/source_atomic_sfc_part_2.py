from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_sfc.employee_group_incr import source_atomic_sfc_employee_group
from etl.source.atomic_sfc.field_incr import source_atomic_sfc_field
from etl.source.atomic_sfc.form_incr import source_atomic_sfc_form
from etl.source.atomic_sfc.form_answer_incr import source_atomic_sfc_form_answer
from etl.source.atomic_sfc.form_question_incr import source_atomic_sfc_form_question
from etl.source.atomic_sfc.form_question_aswer_xref_incr import source_atomic_sfc_form_question_aswer_xref
from etl.source.atomic_sfc.form_question_xref_incr import source_atomic_sfc_form_question_xref
from etl.source.atomic_sfc.form_response_incr import source_atomic_sfc_form_response
from etl.source.atomic_sfc.form_response_detail_incr import source_atomic_sfc_form_response_detail
from etl.source.atomic_sfc.form_stage_xref_incr import source_atomic_sfc_form_stage_xref
from etl.source.atomic_sfc.group_mark_incr import source_atomic_sfc_group_mark
from etl.source.atomic_sfc.group_mark_ref_incr import source_atomic_sfc_group_mark_ref
from etl.source.atomic_sfc.group_operation_production_incr import source_atomic_sfc_group_operation_production
from etl.source.atomic_sfc.group_operation_ref_production_incr import source_atomic_sfc_group_operation_ref_production
from etl.source.atomic_sfc.layout_station_incr import source_atomic_sfc_layout_station
from etl.source.atomic_sfc.layout_station_operation_incr import source_atomic_sfc_layout_station_operation
from etl.source.atomic_sfc.location_incr import source_atomic_sfc_location
from etl.source.atomic_sfc.machine_incr import source_atomic_sfc_machine
from etl.source.atomic_sfc.machine_group_incr import source_atomic_sfc_machine_group
from etl.source.atomic_sfc.mark_incr import source_atomic_sfc_mark

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "employee_group": source_atomic_sfc_employee_group,
    "field": source_atomic_sfc_field,
    "form": source_atomic_sfc_form,
    "form_answer": source_atomic_sfc_form_answer,
    "form_question": source_atomic_sfc_form_question,
    "form_question_aswer_xref": source_atomic_sfc_form_question_aswer_xref,
    "form_question_xref": source_atomic_sfc_form_question_xref,
    "form_response": source_atomic_sfc_form_response,
    "form_response_detail": source_atomic_sfc_form_response_detail,
    "form_stage_xref": source_atomic_sfc_form_stage_xref,
    "group_mark": source_atomic_sfc_group_mark,
    "group_mark_ref": source_atomic_sfc_group_mark_ref,
    "group_operation_production": source_atomic_sfc_group_operation_production,
    "group_operation_ref_production": source_atomic_sfc_group_operation_ref_production,
    "layout_station": source_atomic_sfc_layout_station,
    "layout_station_operation": source_atomic_sfc_layout_station_operation,
    "location": source_atomic_sfc_location,
    "machine": source_atomic_sfc_machine,
    "machine_group": source_atomic_sfc_machine_group,
    "mark": source_atomic_sfc_mark,
}

with DAG(
    dag_id="source_atomic_sfc_part_2",
    default_args=default_args,
    description="Carga de ETLs de Atomic SFC hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_sfc"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["employee_group"] >> tasks["field"] >> tasks["form"] >> tasks["form_answer"]
    tasks["form_question"] >> tasks["form_question_aswer_xref"] >> tasks["form_question_xref"] >> tasks["form_response"]
    tasks["form_response_detail"] >> tasks["form_stage_xref"] >> tasks["group_mark"] >> tasks["group_mark_ref"]
    tasks["group_operation_production"] >> tasks["group_operation_ref_production"] >> tasks["layout_station"] >> tasks["layout_station_operation"]
    tasks["location"] >> tasks["machine"] >> tasks["machine_group"] >> tasks["mark"]