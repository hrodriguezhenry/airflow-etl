from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.etalent.clinical_suspension_incr import source_etalent_clinical_suspension
from etl.source.etalent.clinical_suspension_reason_incr import source_etalent_clinical_suspension_reason
from etl.source.etalent.employee_incr import source_etalent_employee
from etl.source.etalent.employees_incr import source_etalent_employees
from etl.source.etalent.employees_permission_incr import source_etalent_employees_permission
from etl.source.etalent.frozen_payroll_8_incr import source_etalent_frozen_payroll_8
from etl.source.etalent.historical_data_policy_provisions_incr import source_etalent_historical_data_policy_provisions
from etl.source.etalent.historical_data_policy_salary_incr import source_etalent_historical_data_policy_salary
from etl.source.etalent.liquidation_collaborator_detail_incr import source_etalent_liquidation_collaborator_detail
from etl.source.etalent.liquidation_collaborator_incr import source_etalent_liquidation_collaborator
from etl.source.etalent.payroll_history_incr import source_etalent_payroll_history
from etl.source.etalent.payroll_parameters_incr import source_etalent_payroll_parameters
from etl.source.etalent.position_incr import source_etalent_position
from etl.source.etalent.position_profit_center_incr import source_etalent_position_profit_center
from etl.source.etalent.profit_center_incr import source_etalent_profit_center
from etl.source.etalent.reason_liquidation_incr import source_etalent_reason_liquidation
from etl.source.etalent.type_payroll_incr import source_etalent_type_payroll
from etl.source.etalent.unit_incr import source_etalent_unit
from etl.source.etalent.vacation_incr import source_etalent_vacation
from etl.source.etalent.vacations_consumed_incr import source_etalent_vacations_consumed

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "clinical_suspension": source_etalent_clinical_suspension,
    "clinical_suspension_reason": source_etalent_clinical_suspension_reason,
    "employee": source_etalent_employee,
    "employees": source_etalent_employees,
    "employees_permission": source_etalent_employees_permission,
    "frozen_payroll_8": source_etalent_frozen_payroll_8,
    "historical_data_policy_provisions": source_etalent_historical_data_policy_provisions,
    "historical_data_policy_salary": source_etalent_historical_data_policy_salary,
    "liquidation_collaborator_detail": source_etalent_liquidation_collaborator_detail,
    "liquidation_collaborator": source_etalent_liquidation_collaborator,  
    "payroll_history": source_etalent_payroll_history,
    "payroll_parameters": source_etalent_payroll_parameters,
    "position_profit_center": source_etalent_position_profit_center,
    "position": source_etalent_position,
    "profit_center": source_etalent_profit_center,
    "reason_liquidation": source_etalent_reason_liquidation,
    "type_payroll": source_etalent_type_payroll,
    "unit": source_etalent_unit,
    "vacation": source_etalent_vacation,
    "vacations_consumed": source_etalent_vacations_consumed,
}

with DAG(
    dag_id="source_etalent_part_1",
    default_args=default_args,
    description="Carga de ETLs de ETalent hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["etalent"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["clinical_suspension"] >> tasks["clinical_suspension_reason"] >> tasks["employee"] >> tasks["employees"]
    tasks["employees_permission"] >> tasks["frozen_payroll_8"] >> tasks["historical_data_policy_provisions"] >> tasks["historical_data_policy_salary"]
    tasks["liquidation_collaborator_detail"] >> tasks["liquidation_collaborator"] >> tasks["payroll_history"] >> tasks["payroll_parameters"]
    tasks["position_profit_center"] >> tasks["position"] >> tasks["profit_center"] >> tasks["reason_liquidation"]
    tasks["type_payroll"] >> tasks["unit"] >> tasks["vacation"] >> tasks["vacations_consumed"]