from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.osticket.ost_department_incr import source_osticket_ost_department
from etl.source.osticket.ost_help_topic_incr import source_osticket_ost_help_topic
from etl.source.osticket.ost_organization_incr import source_osticket_ost_organization
from etl.source.osticket.ost_sla_incr import source_osticket_ost_sla
from etl.source.osticket.ost_staff_incr import source_osticket_ost_staff
from etl.source.osticket.ost_team_incr import source_osticket_ost_team
from etl.source.osticket.ost_team_member_incr import source_osticket_ost_team_member
from etl.source.osticket.ost_ticket_cdata_incr import source_osticket_ost_ticket_cdata
from etl.source.osticket.ost_ticket_incr import source_osticket_ost_ticket
from etl.source.osticket.ost_ticket_priority_incr import source_osticket_ost_ticket_priority
from etl.source.osticket.ost_ticket_status_incr import source_osticket_ost_ticket_status
from etl.source.osticket.ost_user_incr import source_osticket_ost_user

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "ost_department": source_osticket_ost_department,
    "ost_help_topic": source_osticket_ost_help_topic,
    "ost_organization": source_osticket_ost_organization,
    "ost_sla": source_osticket_ost_sla,
    "ost_staff": source_osticket_ost_staff,
    "ost_team": source_osticket_ost_team,
    "ost_team_member": source_osticket_ost_team_member,
    "ost_ticket_priority": source_osticket_ost_ticket_priority,
    "ost_ticket_status": source_osticket_ost_ticket_status,
    "ost_ticket": source_osticket_ost_ticket,
    "ost_ticket_cdata": source_osticket_ost_ticket_cdata,
    "ost_user": source_osticket_ost_user,
}

with DAG(
    dag_id="source_osticket",
    default_args=default_args,
    description="Carga de ETLs de OSTicket hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["osticket"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["ost_department"] >> tasks["ost_help_topic"] >> tasks["ost_organization"] >> tasks["ost_sla"]
    tasks["ost_staff"] >> tasks["ost_team"] >> tasks["ost_team_member"] >> tasks["ost_sla"]
    tasks["ost_ticket_priority"] >> tasks["ost_ticket_status"] >> tasks["ost_ticket"] >> tasks["ost_ticket_cdata"]
    tasks["ost_user"]