from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.proaktiv.po_type_incr import source_proaktiv_po_type
from etl.source.proaktiv.prod_lines_incr import source_proaktiv_prod_lines
from etl.source.proaktiv.reasons_incr import source_proaktiv_reasons
from etl.source.proaktiv.reasons_remove_peps_incr import source_proaktiv_reasons_remove_peps
from etl.source.proaktiv.retailers_incr import source_proaktiv_retailers
from etl.source.proaktiv.rmi_incr import source_proaktiv_rmi
from etl.source.proaktiv.rmi_leathers_formats_incr import source_proaktiv_rmi_leathers_formats
from etl.source.proaktiv.rmi_repos_incr import source_proaktiv_rmi_repos
from etl.source.proaktiv.ship_to_incr import source_proaktiv_ship_to
from etl.source.proaktiv.slack_incr import source_proaktiv_slack
from etl.source.proaktiv.stl_cls_incr import source_proaktiv_stl_cls
from etl.source.proaktiv.style_details_incr import source_proaktiv_style_details
from etl.source.proaktiv.styles_incr import source_proaktiv_styles
from etl.source.proaktiv.supermarket_rmi_ticket_incr import source_proaktiv_supermarket_rmi_ticket
from etl.source.proaktiv.supermarket_status_incr import source_proaktiv_supermarket_status
from etl.source.proaktiv.sz_dim_detail_incr import source_proaktiv_sz_dim_detail
from etl.source.proaktiv.sz_dim_incr import source_proaktiv_sz_dim
from etl.source.proaktiv.transit_time_incr import source_proaktiv_transit_time
from etl.source.proaktiv.uom_incr import source_proaktiv_uom
from etl.source.proaktiv.users_incr import source_proaktiv_users

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "po_type": source_proaktiv_po_type,
    "prod_lines": source_proaktiv_prod_lines,
    "reasons": source_proaktiv_reasons,
    "reasons_remove_peps": source_proaktiv_reasons_remove_peps,
    "retailers": source_proaktiv_retailers,
    "rmi": source_proaktiv_rmi,
    "rmi_leathers_formats": source_proaktiv_rmi_leathers_formats,
    "rmi_repos": source_proaktiv_rmi_repos,
    "ship_to": source_proaktiv_ship_to,
    "slack": source_proaktiv_slack,
    "stl_cls": source_proaktiv_stl_cls,
    "style_details": source_proaktiv_style_details,
    "styles": source_proaktiv_styles,
    "supermarket_status": source_proaktiv_supermarket_status,
    "supermarket_rmi_ticket": source_proaktiv_supermarket_rmi_ticket,
    "sz_dim": source_proaktiv_sz_dim,
    "sz_dim_detail": source_proaktiv_sz_dim_detail,
    "transit_time": source_proaktiv_transit_time,
    "uom": source_proaktiv_uom,
    "users": source_proaktiv_users,
}

with DAG(
    dag_id="source_proaktiv_part_3",
    default_args=default_args,
    description="Carga de ETLs de Proaktiv hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["proaktiv"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["po_type"] >> tasks["prod_lines"] >> tasks["reasons"] >> tasks["reasons_remove_peps"]
    tasks["retailers"] >> tasks["rmi"] >> tasks["rmi_leathers_formats"] >> tasks["rmi_repos"]
    tasks["ship_to"] >> tasks["slack"] >> tasks["stl_cls"] >> tasks["style_details"]
    tasks["styles"] >> tasks["supermarket_status"] >> tasks["supermarket_rmi_ticket"] >> tasks["sz_dim"]
    tasks["sz_dim_detail"] >> tasks["transit_time"] >> tasks["uom"] >> tasks["users"]