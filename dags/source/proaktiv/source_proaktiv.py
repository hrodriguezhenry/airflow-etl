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
from etl.source.proaktiv.vendors_incr import source_proaktiv_vendors
from etl.source.proaktiv.vendors_information_incr import source_proaktiv_vendors_information
from etl.source.proaktiv.vias_incr import source_proaktiv_vias
from etl.source.proaktiv.warehouses_incr import source_proaktiv_warehouses
from etl.source.proaktiv.weights_specific_expenses_incr import source_proaktiv_weights_specific_expenses

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
    "vendors": source_proaktiv_vendors,
    "vendors_information": source_proaktiv_vendors_information,
    "vias": source_proaktiv_vias,
    "warehouses": source_proaktiv_warehouses,
    "weights_specific_expenses": source_proaktiv_weights_specific_expenses,
}

with DAG(
    dag_id="source_proaktiv",
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

    dependency_order = list(ETL_TASKS.keys())
    for upstream, downstream in zip(dependency_order, dependency_order[1:]):
        tasks[upstream] >> tasks[downstream]