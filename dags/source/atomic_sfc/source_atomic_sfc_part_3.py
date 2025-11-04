import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_sfc.mark_event_incr import source_atomic_sfc_mark_event
from etl.source.atomic_sfc.mark_event_support_incr import source_atomic_sfc_mark_event_support
from etl.source.atomic_sfc.mark_event_type_incr import source_atomic_sfc_mark_event_type
from etl.source.atomic_sfc.material_class_group_incr import source_atomic_sfc_material_class_group
from etl.source.atomic_sfc.material_class_group_ref_incr import source_atomic_sfc_material_class_group_ref
from etl.source.atomic_sfc.microzone_incr import source_atomic_sfc_microzone
from etl.source.atomic_sfc.operation_exit_production_incr import source_atomic_sfc_operation_exit_production
from etl.source.atomic_sfc.operation_production_incr import source_atomic_sfc_operation_production
from etl.source.atomic_sfc.operation_rmi_incr import source_atomic_sfc_operation_rmi
from etl.source.atomic_sfc.order_status_incr import source_atomic_sfc_order_status
from etl.source.atomic_sfc.plant_incr import source_atomic_sfc_plant
from etl.source.atomic_sfc.production_advance_incr import source_atomic_sfc_production_advance
from etl.source.atomic_sfc.production_route_incr import source_atomic_sfc_production_route
from etl.source.atomic_sfc.production_scan_incr import source_atomic_sfc_production_scan
from etl.source.atomic_sfc.reason_incr import source_atomic_sfc_reason
from etl.source.atomic_sfc.reposition_incr import source_atomic_sfc_reposition
from etl.source.atomic_sfc.sam_incr import source_atomic_sfc_sam
from etl.source.atomic_sfc.sam_specific_incr import source_atomic_sfc_sam_specific
from etl.source.atomic_sfc.sam_specific_field_xref_incr import source_atomic_sfc_sam_specific_field_xref
from etl.source.atomic_sfc.sam_specific_operation_xref_incr import source_atomic_sfc_sam_specific_operation_xref

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "mark_event": source_atomic_sfc_mark_event,
    "mark_event_support": source_atomic_sfc_mark_event_support,
    "mark_event_type": source_atomic_sfc_mark_event_type,
    "material_class_group": source_atomic_sfc_material_class_group,
    "material_class_group_ref": source_atomic_sfc_material_class_group_ref,
    "microzone": source_atomic_sfc_microzone,
    "operation_exit_production": source_atomic_sfc_operation_exit_production,
    "operation_production": source_atomic_sfc_operation_production,
    "operation_rmi": source_atomic_sfc_operation_rmi,
    "order_status": source_atomic_sfc_order_status,
    "plant": source_atomic_sfc_plant,
    "production_advance": source_atomic_sfc_production_advance,
    "production_route": source_atomic_sfc_production_route,
    "production_scan": source_atomic_sfc_production_scan,
    "reason": source_atomic_sfc_reason,
    "reposition": source_atomic_sfc_reposition,
    "sam": source_atomic_sfc_sam,
    "sam_specific": source_atomic_sfc_sam_specific,
    "sam_specific_field_xref": source_atomic_sfc_sam_specific_field_xref,
    "sam_specific_operation_xref": source_atomic_sfc_sam_specific_operation_xref,
}

with DAG(
    dag_id="source_atomic_sfc_part_3",
    default_args=default_args,
    description="Carga parcial (20 ETLs) de Atomic SFC hacia Tatabi",
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

    tasks["mark_event"] >> tasks["mark_event_support"] >> tasks["mark_event_type"] >> tasks["material_class_group"]
    tasks["material_class_group_ref"] >> tasks["microzone"] >> tasks["operation_exit_production"] >> tasks["operation_production"]
    tasks["operation_rmi"] >> tasks["order_status"] >> tasks["plant"] >> tasks["production_advance"]
    tasks["production_route"] >> tasks["production_scan"] >> tasks["reason"] >> tasks["reposition"]
    tasks["sam"] >> tasks["sam_specific"] >> tasks["sam_specific_field_xref"] >> tasks["sam_specific_operation_xref"]
