import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.proaktiv.audit_incr import source_proaktiv_audit
from etl.source.proaktiv.aut_peps_incr import source_proaktiv_aut_peps
from etl.source.proaktiv.aut_peps_pt_incr import source_proaktiv_aut_peps_pt
from etl.source.proaktiv.bom_incr import source_proaktiv_bom
from etl.source.proaktiv.bom_user_incr import source_proaktiv_bom_user
from etl.source.proaktiv.buckle_type_incr import source_proaktiv_buckle_type
from etl.source.proaktiv.colors_incr import source_proaktiv_colors
from etl.source.proaktiv.countries_incr import source_proaktiv_countries
from etl.source.proaktiv.cust_ord_aud_incr import source_proaktiv_cust_ord_aud
from etl.source.proaktiv.cust_ord_detail_incr import source_proaktiv_cust_ord_detail
from etl.source.proaktiv.cust_ord_hdr_incr import source_proaktiv_cust_ord_hdr
from etl.source.proaktiv.cust_ord_type_incr import source_proaktiv_cust_ord_type
from etl.source.proaktiv.customers_incr import source_proaktiv_customers
from etl.source.proaktiv.cut_pl_incr import source_proaktiv_cut_pl
from etl.source.proaktiv.cut_pl_reposition_incr import source_proaktiv_cut_pl_reposition
from etl.source.proaktiv.cut_style_fr_incr import source_proaktiv_cut_style_fr
from etl.source.proaktiv.cuts_incr import source_proaktiv_cuts
from etl.source.proaktiv.delivery_price_sap_incr import source_proaktiv_delivery_price_sap
from etl.source.proaktiv.denures_incr import source_proaktiv_denures
from etl.source.proaktiv.exch_rate_incr import source_proaktiv_exch_rate

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "audit": source_proaktiv_audit,
    "aut_peps": source_proaktiv_aut_peps,
    "aut_peps_pt": source_proaktiv_aut_peps_pt,
    "bom": source_proaktiv_bom,
    "bom_user": source_proaktiv_bom_user,
    "buckle_type": source_proaktiv_buckle_type,
    "colors": source_proaktiv_colors,
    "countries": source_proaktiv_countries,
    "cust_ord_aud": source_proaktiv_cust_ord_aud,
    "cust_ord_detail": source_proaktiv_cust_ord_detail,
    "cust_ord_hdr": source_proaktiv_cust_ord_hdr,
    "cust_ord_type": source_proaktiv_cust_ord_type,
    "customers": source_proaktiv_customers,
    "cut_pl": source_proaktiv_cut_pl,
    "cut_pl_reposition": source_proaktiv_cut_pl_reposition,
    "cut_style_fr": source_proaktiv_cut_style_fr,
    "cuts": source_proaktiv_cuts,
    "delivery_price_sap": source_proaktiv_delivery_price_sap,
    "denures": source_proaktiv_denures,
    "exch_rate": source_proaktiv_exch_rate,
}

with DAG(
    dag_id="source_proaktiv_part_1",
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

    tasks["audit"] >> tasks["aut_peps"] >> tasks["aut_peps_pt"] >> tasks["bom"]
    tasks["bom_user"] >> tasks["buckle_type"] >> tasks["colors"] >> tasks["countries"]
    tasks["cust_ord_aud"] >> tasks["cust_ord_detail"] >> tasks["cust_ord_hdr"] >> tasks["cust_ord_type"]
    tasks["customers"] >> tasks["cut_pl"] >> tasks["cut_pl_reposition"] >> tasks["cut_style_fr"]
    tasks["cuts"] >> tasks["delivery_price_sap"] >> tasks["denures"] >> tasks["exch_rate"]