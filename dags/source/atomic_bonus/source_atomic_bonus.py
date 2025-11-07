from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.atomic_bonus.efficiency_area_detail_incr import source_atomic_bonus_efficiency_area_detail
from etl.source.atomic_bonus.efficiency_area_incr import source_atomic_bonus_efficiency_area
from etl.source.atomic_bonus.efficiency_daily_history_incr import source_atomic_bonus_efficiency_daily_history
from etl.source.atomic_bonus.efficiency_daily_history_reject_incr import source_atomic_bonus_efficiency_daily_history_reject
from etl.source.atomic_bonus.efficiency_daily_history_waste_incr import source_atomic_bonus_efficiency_daily_history_waste
from etl.source.atomic_bonus.efficiency_history_incr import source_atomic_bonus_efficiency_history
from etl.source.atomic_bonus.efficiency_history_reject_incr import source_atomic_bonus_efficiency_history_reject
from etl.source.atomic_bonus.efficiency_history_waste_incr import source_atomic_bonus_efficiency_history_waste
from etl.source.atomic_bonus.efficiency_station_system_log_incr import source_atomic_bonus_efficiency_station_system_log
from etl.source.atomic_bonus.employee_area_detail_incr import source_atomic_bonus_employee_area_detail
from etl.source.atomic_bonus.employee_area_incr import source_atomic_bonus_employee_area
from etl.source.atomic_bonus.employee_history_incr import source_atomic_bonus_employee_history
from etl.source.atomic_bonus.employee_leader_incr import source_atomic_bonus_employee_leader
from etl.source.atomic_bonus.operation_log_incr import source_atomic_bonus_operation_log

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "efficiency_area_detail": source_atomic_bonus_efficiency_area_detail,
    "efficiency_area": source_atomic_bonus_efficiency_area,
    "efficiency_daily_history": source_atomic_bonus_efficiency_daily_history,
    "efficiency_daily_history_reject": source_atomic_bonus_efficiency_daily_history_reject,
    "efficiency_daily_history_waste": source_atomic_bonus_efficiency_daily_history_waste,
    "efficiency_history": source_atomic_bonus_efficiency_history,
    "efficiency_history_reject": source_atomic_bonus_efficiency_history_reject,
    "efficiency_history_waste": source_atomic_bonus_efficiency_history_waste,
    "efficiency_station_system_log": source_atomic_bonus_efficiency_station_system_log,
    "employee_area_detail": source_atomic_bonus_employee_area_detail,
    "employee_area": source_atomic_bonus_employee_area,
    "employee_history": source_atomic_bonus_employee_history,
    "employee_leader": source_atomic_bonus_employee_leader,
    "operation_log": source_atomic_bonus_operation_log,
}

with DAG(
    dag_id="source_atomic_bonus",
    default_args=default_args,
    description="Carga de ETLs de Atomic Bonus hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_bonus"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["efficiency_area_detail"] >> tasks["efficiency_area"] >> tasks["efficiency_daily_history"] >> tasks["efficiency_daily_history_reject"]
    tasks["efficiency_daily_history_waste"] >> tasks["efficiency_history"] >> tasks["efficiency_history_reject"] >> tasks["efficiency_history_waste"]
    tasks["efficiency_station_system_log"] >> tasks["employee_area_detail"] >> tasks["employee_area"] >> tasks["employee_history"]
    tasks["employee_leader"] >> tasks["operation_log"]