import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.atomic_aql.defect_incr import source_atomic_aql_defect
from etl.source.atomic_aql.military_incr import source_atomic_aql_military
from etl.source.atomic_aql.rmi_acceptation_level_incr import source_atomic_aql_rmi_acceptation_level
from etl.source.atomic_aql.rmi_box_acceptance_incr import source_atomic_aql_rmi_box_acceptance
from etl.source.atomic_aql.rmi_inspection_level_incr import source_atomic_aql_rmi_inspection_level
from etl.source.atomic_aql.rmi_revision_detail_batch_incr import source_atomic_aql_rmi_revision_detail_batch
from etl.source.atomic_aql.rmi_revision_detail_box_defect_incr import source_atomic_aql_rmi_revision_detail_box_defect
from etl.source.atomic_aql.rmi_revision_detail_box_incr import source_atomic_aql_rmi_revision_detail_box
from etl.source.atomic_aql.rmi_revision_detail_incr import source_atomic_aql_rmi_revision_detail
from etl.source.atomic_aql.rmi_revision_incr import source_atomic_aql_rmi_revision
from etl.source.atomic_aql.rmi_unit_revision_incr import source_atomic_aql_rmi_unit_revision

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="source_atomic_aql",
    default_args=default_args,
    description="Carga de ETls de Atomic AQL hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["atomic_aql"],
) as dag:

    defect = PythonOperator(
        task_id="defect",
        python_callable=source_atomic_aql_defect
    )
    
    military = PythonOperator(
        task_id="military",
        python_callable=source_atomic_aql_military
    )
        
    rmi_acceptation_level = PythonOperator(
        task_id="rmi_acceptation_level",
        python_callable=source_atomic_aql_rmi_acceptation_level
    )
            
    rmi_box_acceptance = PythonOperator(
        task_id="rmi_box_acceptance",
        python_callable=source_atomic_aql_rmi_box_acceptance
    )
                
    rmi_inspection_level = PythonOperator(
        task_id="rmi_inspection_level",
        python_callable=source_atomic_aql_rmi_inspection_level
    )
                    
    rmi_revision_detail_batch = PythonOperator(
        task_id="rmi_revision_detail_batch",
        python_callable=source_atomic_aql_rmi_revision_detail_batch
    )
    
    rmi_revision_detail_box_defect = PythonOperator(
        task_id="rmi_revision_detail_box_defect",
        python_callable=source_atomic_aql_rmi_revision_detail_box_defect
    )
    
    rmi_revision_detail_box = PythonOperator(
        task_id="rmi_revision_detail_box",
        python_callable=source_atomic_aql_rmi_revision_detail_box
    )
    
    rmi_revision_detail = PythonOperator(
        task_id="rmi_revision_detail",
        python_callable=source_atomic_aql_rmi_revision_detail
    )
    
    rmi_revision = PythonOperator(
        task_id="rmi_revision",
        python_callable=source_atomic_aql_rmi_revision
    )
    
    rmi_unit_revision = PythonOperator(
        task_id="rmi_unit_revision",
        python_callable=source_atomic_aql_rmi_unit_revision
    )

    defect >> military >> rmi_acceptation_level >> rmi_box_acceptance >> rmi_inspection_level
    rmi_revision_detail_batch >> rmi_revision_detail_box_defect >> rmi_revision_detail_box >> rmi_revision_detail
    rmi_revision >> rmi_unit_revision