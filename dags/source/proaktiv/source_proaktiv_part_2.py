from datetime import datetime, timedelta
from pathlib import Path
import sys
import os

ROOT_DIR = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT_DIR))

from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.proaktiv.exch_rate_multi_incr import source_proaktiv_exch_rate_multi
from etl.source.proaktiv.exchange_rate_sap_incr import source_proaktiv_exchange_rate_sap
from etl.source.proaktiv.fgi_incr import source_proaktiv_fgi
from etl.source.proaktiv.fgi_output_hour_incr import source_proaktiv_fgi_output_hour
from etl.source.proaktiv.fgi_output_hour_detail_incr import source_proaktiv_fgi_output_hour_detail
from etl.source.proaktiv.h_transport_detail_incr import source_proaktiv_h_transport_detail
from etl.source.proaktiv.h_transport_hdr_incr import source_proaktiv_h_transport_hdr
from etl.source.proaktiv.imp_cod_hdr_incr import source_proaktiv_imp_cod_hdr
from etl.source.proaktiv.lead_times_gtm_incr import source_proaktiv_lead_times_gtm
from etl.source.proaktiv.locations_incr import source_proaktiv_locations
from etl.source.proaktiv.log_po_hdr_incr import source_proaktiv_log_po_hdr
from etl.source.proaktiv.mat_cls_incr import source_proaktiv_mat_cls
from etl.source.proaktiv.mat_cls_inv_type_incr import source_proaktiv_mat_cls_inv_type
from etl.source.proaktiv.mat_net_position_incr import source_proaktiv_mat_net_position
from etl.source.proaktiv.materials_alt_vendor_incr import source_proaktiv_materials_alt_vendor
from etl.source.proaktiv.materials_incr import source_proaktiv_materials
from etl.source.proaktiv.packaging_specifications_incr import source_proaktiv_packaging_specifications
from etl.source.proaktiv.pattern_incr import source_proaktiv_pattern
from etl.source.proaktiv.po_detail_incr import source_proaktiv_po_detail
from etl.source.proaktiv.po_hdr_incr import source_proaktiv_po_hdr

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "exch_rate_multi": source_proaktiv_exch_rate_multi,
    "exchange_rate_sap": source_proaktiv_exchange_rate_sap,
    "fgi": source_proaktiv_fgi,
    "fgi_output_hour": source_proaktiv_fgi_output_hour,
    "fgi_output_hour_detail": source_proaktiv_fgi_output_hour_detail,
    "h_transport_hdr": source_proaktiv_h_transport_hdr,
    "h_transport_detail": source_proaktiv_h_transport_detail,
    "imp_cod_hdr": source_proaktiv_imp_cod_hdr,
    "lead_times_gtm": source_proaktiv_lead_times_gtm,
    "locations": source_proaktiv_locations,
    "log_po_hdr": source_proaktiv_log_po_hdr,
    "mat_cls": source_proaktiv_mat_cls,
    "mat_cls_inv_type": source_proaktiv_mat_cls_inv_type,
    "mat_net_position": source_proaktiv_mat_net_position,
    "materials": source_proaktiv_materials,
    "materials_alt_vendor": source_proaktiv_materials_alt_vendor,
    "packaging_specifications": source_proaktiv_packaging_specifications,
    "pattern": source_proaktiv_pattern,
    "po_hdr": source_proaktiv_po_hdr,
    "po_detail": source_proaktiv_po_detail,
}

with DAG(
    dag_id="source_proaktiv_part_2",
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

    tasks["exch_rate_multi"] >> tasks["exchange_rate_sap"] >> tasks["fgi"] >> tasks["fgi_output_hour"]
    tasks["fgi_output_hour_detail"] >> tasks["h_transport_hdr"] >> tasks["h_transport_detail"] >> tasks["imp_cod_hdr"]
    tasks["lead_times_gtm"] >> tasks["locations"] >> tasks["log_po_hdr"] >> tasks["mat_cls"]
    tasks["mat_cls_inv_type"] >> tasks["mat_net_position"] >> tasks["materials"] >> tasks["materials_alt_vendor"]
    tasks["packaging_specifications"] >> tasks["pattern"] >> tasks["po_hdr"] >> tasks["po_detail"]