from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from etl.source.geoschools.department_incr import geoschools_department
from etl.source.geoschools.favorite_incr import geoschools_favorite
from etl.source.geoschools.municipality_incr import geoschools_municipality
from etl.source.geoschools.review_incr import geoschools_review
from etl.source.geoschools.school_level_incr import geoschools_school_level
from etl.source.geoschools.school_incr import geoschools_school
from etl.source.geoschools.user_incr import geoschools_user

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="source_example_part_1",
    default_args=default_args,
    description="Carga de tablas hacia DWH",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["example"],
) as dag:

    ETL1 = PythonOperator(
        task_id="ETL1",
        python_callable=geoschools_department
    )
    
    ETL2 = PythonOperator(
        task_id="ETL2",
        python_callable=geoschools_favorite
    )
    
    ETL3 = PythonOperator(
        task_id="ETL3",
        python_callable=geoschools_municipality
    )
    
    ETL4 = PythonOperator(
        task_id="ETL4",
        python_callable=geoschools_review
    )
    
    ETL5 = PythonOperator(
        task_id="ETL5",
        python_callable=geoschools_school_level
    )
    
    ETL6 = PythonOperator(
        task_id="ETL6",
        python_callable=geoschools_school
    )
    
    ETL7 = PythonOperator(
        task_id="ETL7",
        python_callable=geoschools_user
    )
    
    ETL1 >> ETL2 >> ETL3 >> ETL4
    ETL5 >> ETL6 >> ETL7