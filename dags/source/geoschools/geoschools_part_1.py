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
    dag_id="source_geoschools_part_1",
    default_args=default_args,
    description="Carga de tablas desde geoschools hacia DWH",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["geoschools"],
) as dag:

    department = PythonOperator(
        task_id="source_geoschools_department",
        python_callable=geoschools_department
    )
    
    favorite = PythonOperator(
        task_id="source_geoschools_favorite",
        python_callable=geoschools_favorite
    )
    
    municipality = PythonOperator(
        task_id="source_geoschools_municipality",
        python_callable=geoschools_municipality
    )
    
    review = PythonOperator(
        task_id="source_geoschools_review",
        python_callable=geoschools_review
    )
    
    school_level = PythonOperator(
        task_id="source_geoschools_school_level",
        python_callable=geoschools_school_level
    )
    
    school = PythonOperator(
        task_id="source_geoschools_school",
        python_callable=geoschools_school
    )
    
    user = PythonOperator(
        task_id="source_geoschools_user",
        python_callable=geoschools_user
    )
    
    department >> favorite >> municipality >> review
    school_level >> school >> user