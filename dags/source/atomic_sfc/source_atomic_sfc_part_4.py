from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_sfc.scan_qr_incr import source_atomic_sfc_scan_qr
from etl.source.atomic_sfc.scan_qr_detail_incr import source_atomic_sfc_scan_qr_detail
from etl.source.atomic_sfc.scan_transact_cost_incr import source_atomic_sfc_scan_transact_cost
from etl.source.atomic_sfc.scan_transact_cost_account_incr import source_atomic_sfc_scan_transact_cost_account
from etl.source.atomic_sfc.scan_transact_cust_item_incr import source_atomic_sfc_scan_transact_cust_item
from etl.source.atomic_sfc.scan_transact_production_incr import source_atomic_sfc_scan_transact_production
from etl.source.atomic_sfc.scan_transact_rmi_incr import source_atomic_sfc_scan_transact_rmi
from etl.source.atomic_sfc.setup_change_incr import source_atomic_sfc_setup_change
from etl.source.atomic_sfc.setup_variable_incr import source_atomic_sfc_setup_variable
from etl.source.atomic_sfc.setup_variable_value_incr import source_atomic_sfc_setup_variable_value
from etl.source.atomic_sfc.setup_zero_box_incr import source_atomic_sfc_setup_zero_box
from etl.source.atomic_sfc.size_detail_incr import source_atomic_sfc_size_detail
from etl.source.atomic_sfc.statistics_incr import source_atomic_sfc_statistics
from etl.source.atomic_sfc.statistics_detail_incr import source_atomic_sfc_statistics_detail
from etl.source.atomic_sfc.style_class_layer_incr import source_atomic_sfc_style_class_layer
from etl.source.atomic_sfc.style_route_error_log_incr import source_atomic_sfc_style_route_error_log
from etl.source.atomic_sfc.style_route_production_incr import source_atomic_sfc_style_route_production
from etl.source.atomic_sfc.support_closure_type_category_incr import source_atomic_sfc_support_closure_type_category
from etl.source.atomic_sfc.type_distribution_cost_cost_center_incr import source_atomic_sfc_type_distribution_cost_cost_center

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "scan_qr": source_atomic_sfc_scan_qr,
    "scan_qr_detail": source_atomic_sfc_scan_qr_detail,
    "scan_transact_cost": source_atomic_sfc_scan_transact_cost,
    "scan_transact_cost_account": source_atomic_sfc_scan_transact_cost_account,
    "scan_transact_cust_item": source_atomic_sfc_scan_transact_cust_item,
    "scan_transact_production": source_atomic_sfc_scan_transact_production,
    "scan_transact_rmi": source_atomic_sfc_scan_transact_rmi,
    "setup_change": source_atomic_sfc_setup_change,
    "setup_variable": source_atomic_sfc_setup_variable,
    "setup_variable_value": source_atomic_sfc_setup_variable_value,
    "setup_zero_box": source_atomic_sfc_setup_zero_box,
    "size_detail": source_atomic_sfc_size_detail,
    "statistics": source_atomic_sfc_statistics,
    "statistics_detail": source_atomic_sfc_statistics_detail,
    "style_class_layer": source_atomic_sfc_style_class_layer,
    "style_route_error_log": source_atomic_sfc_style_route_error_log,
    "style_route_production": source_atomic_sfc_style_route_production,
    "support_closure_type_category": source_atomic_sfc_support_closure_type_category,
    "type_distribution_cost_cost_center": source_atomic_sfc_type_distribution_cost_cost_center,
}

with DAG(
    dag_id="source_atomic_sfc_part_4",
    default_args=default_args,
    description="Carga parcial (20 ETLs desde scan_qr) de Atomic SFC hacia Tatabi",
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
    
    tasks["scan_qr"] >> tasks["scan_qr_detail"] >> tasks["scan_transact_cost"] >> tasks["scan_transact_cost_account"]
    tasks["scan_transact_cust_item"] >> tasks["scan_transact_production"] >> tasks["scan_transact_rmi"] >> tasks["setup_change"]
    tasks["setup_variable"] >> tasks["setup_variable_value"] >> tasks["setup_zero_box"] >> tasks["size_detail"]
    tasks["statistics"] >> tasks["statistics_detail"] >> tasks["style_class_layer"] >> tasks["style_route_error_log"]
    tasks["style_route_production"] >> tasks["support_closure_type_category"] >> tasks["type_distribution_cost_cost_center"]