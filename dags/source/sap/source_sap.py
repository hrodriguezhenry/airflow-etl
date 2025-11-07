from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.sap.ges1_incr import source_sap_ges1
from etl.source.sap.ige1_incr import source_sap_ige1
from etl.source.sap.ipf1_incr import source_sap_ipf1
from etl.source.sap.ipf2_incr import source_sap_ipf2
from etl.source.sap.jdt1_incr import source_sap_jdt1
from etl.source.sap.ocrd_incr import source_sap_ocrd
from etl.source.sap.oige_incr import source_sap_oige
from etl.source.sap.oinm_incr import source_sap_oinm
from etl.source.sap.oipf_incr import source_sap_oipf
from etl.source.sap.oitb_incr import source_sap_oitb
from etl.source.sap.oitm_incr import source_sap_oitm
from etl.source.sap.oitw_incr import source_sap_oitw
from etl.source.sap.ojdt_incr import source_sap_ojdt
from etl.source.sap.opdn_incr import source_sap_opdn
from etl.source.sap.opor_incr import source_sap_opor
from etl.source.sap.ortt_incr import source_sap_ortt
from etl.source.sap.owhs_incr import source_sap_owhs
from etl.source.sap.pdn1_incr import source_sap_pdn1
from etl.source.sap.por1_incr import source_sap_por1

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "ocrd": source_sap_ocrd,
    "oitb": source_sap_oitb,
    "oitm": source_sap_oitm,
    "owhs": source_sap_owhs,
    
    "oitw": source_sap_oitw,
    "ortt": source_sap_ortt,
    "ojdt": source_sap_ojdt,
    "jdt1": source_sap_jdt1,
    
    "opor": source_sap_opor,
    "por1": source_sap_por1,
    "opdn": source_sap_opdn,
    "pdn1": source_sap_pdn1,
    
    "oige": source_sap_oige,
    "ige1": source_sap_ige1,
    "oinm": source_sap_oinm,
    "oipf": source_sap_oipf,
    
    "ipf1": source_sap_ipf1,
    "ipf2": source_sap_ipf2,
    "ges1": source_sap_ges1,
}

with DAG(
    dag_id="source_sap",
    default_args=default_args,
    description="Carga de ETLs de SAP hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["sap"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["ocrd"] >> tasks["oitb"] >> tasks["oitm"] >> tasks["owhs"]
    tasks["oitw"] >> tasks["ortt"] >> tasks["ojdt"] >> tasks["jdt1"]
    tasks["opor"] >> tasks["por1"] >> tasks["opdn"] >> tasks["pdn1"]
    tasks["oige"] >> tasks["ige1"] >> tasks["oinm"] >> tasks["oipf"]
    tasks["ipf1"] >> tasks["ipf2"] >> tasks["ges1"]