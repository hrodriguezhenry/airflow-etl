from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_sfc.advance_quality_audit_incr import source_atomic_sfc_advance_quality_audit
from etl.source.atomic_sfc.certified_operator_incr import source_atomic_sfc_certified_operator
from etl.source.atomic_sfc.configuration_incr import source_atomic_sfc_configuration
from etl.source.atomic_sfc.course_incr import source_atomic_sfc_course
from etl.source.atomic_sfc.course_instructor_incr import source_atomic_sfc_course_instructor
from etl.source.atomic_sfc.course_instructor_operation_xref_incr import source_atomic_sfc_course_instructor_operation_xref
from etl.source.atomic_sfc.course_instructor_student_incr import source_atomic_sfc_course_instructor_student
from etl.source.atomic_sfc.course_operation_xref_incr import source_atomic_sfc_course_operation_xref
from etl.source.atomic_sfc.course_resource_incr import source_atomic_sfc_course_resource
from etl.source.atomic_sfc.course_student_evaluation_incr import source_atomic_sfc_course_student_evaluation
from etl.source.atomic_sfc.course_student_evaluation_resource_incr import source_atomic_sfc_course_student_evaluation_resource
from etl.source.atomic_sfc.course_student_operation_xref_incr import source_atomic_sfc_course_student_operation_xref
from etl.source.atomic_sfc.course_type_incr import source_atomic_sfc_course_type
from etl.source.atomic_sfc.daily_cost_incr import source_atomic_sfc_daily_cost
from etl.source.atomic_sfc.daily_cost_account_incr import source_atomic_sfc_daily_cost_account
from etl.source.atomic_sfc.detail_reposition_incr import source_atomic_sfc_detail_reposition
from etl.source.atomic_sfc.devolution_incr import source_atomic_sfc_devolution
from etl.source.atomic_sfc.devolution_detail_incr import source_atomic_sfc_devolution_detail
from etl.source.atomic_sfc.devolution_order_incr import source_atomic_sfc_devolution_order
from etl.source.atomic_sfc.efficiency_consolidated_incr import source_atomic_sfc_efficiency_consolidated

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "advance_quality_audit": source_atomic_sfc_advance_quality_audit,
    "certified_operator": source_atomic_sfc_certified_operator,
    "configuration": source_atomic_sfc_configuration,
    "course": source_atomic_sfc_course,
    "course_instructor": source_atomic_sfc_course_instructor,
    "course_instructor_operation_xref": source_atomic_sfc_course_instructor_operation_xref,
    "course_instructor_student": source_atomic_sfc_course_instructor_student,
    "course_operation_xref": source_atomic_sfc_course_operation_xref,
    "course_resource": source_atomic_sfc_course_resource,
    "course_student_evaluation": source_atomic_sfc_course_student_evaluation,
    "course_student_evaluation_resource": source_atomic_sfc_course_student_evaluation_resource,
    "course_student_operation_xref": source_atomic_sfc_course_student_operation_xref,
    "course_type": source_atomic_sfc_course_type,
    "daily_cost": source_atomic_sfc_daily_cost,
    "daily_cost_account": source_atomic_sfc_daily_cost_account,
    "detail_reposition": source_atomic_sfc_detail_reposition,
    "devolution": source_atomic_sfc_devolution,
    "devolution_detail": source_atomic_sfc_devolution_detail,
    "devolution_order": source_atomic_sfc_devolution_order,
    "efficiency_consolidated": source_atomic_sfc_efficiency_consolidated,
}


with DAG(
    dag_id="source_atomic_sfc_part_1",
    default_args=default_args,
    description="Carga de ETLs de Atomic SFC hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_sfc"],
) as dag:

    # === Crear tareas dinámicamente ===
    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["advance_quality_audit"] >> tasks["certified_operator"] >> tasks["configuration"] >> tasks["course"]
    tasks["course_instructor"] >> tasks["course_instructor_operation_xref"] >> tasks["course_instructor_student"] >> tasks["course_operation_xref"]
    tasks["course_resource"] >> tasks["course_student_evaluation"] >> tasks["course_student_evaluation_resource"] >> tasks["course_student_operation_xref"]
    tasks["course_type"] >> tasks["daily_cost"] >> tasks["daily_cost_account"] >> tasks["detail_reposition"]
    tasks["devolution"] >> tasks["devolution_detail"] >> tasks["devolution_order"] >> tasks["efficiency_consolidated"]