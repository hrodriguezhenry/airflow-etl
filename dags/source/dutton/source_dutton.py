import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

from etl.source.dutton.boxes_incr import source_dutton_boxes
from etl.source.dutton.categories_incr import source_dutton_categories
from etl.source.dutton.colors_incr import source_dutton_colors
from etl.source.dutton.comments_incr import source_dutton_comments
from etl.source.dutton.customer_quote_details_incr import source_dutton_customer_quote_details
from etl.source.dutton.customers_incr import source_dutton_customers
from etl.source.dutton.price_list_product_variant_incr import source_dutton_price_list_product_variant
from etl.source.dutton.price_lists_incr import source_dutton_price_lists
from etl.source.dutton.product_images_incr import source_dutton_product_images
from etl.source.dutton.product_variants_incr import source_dutton_product_variants
from etl.source.dutton.products_incr import source_dutton_products
from etl.source.dutton.sizes_incr import source_dutton_sizes
from etl.source.dutton.stocks_incr import source_dutton_stocks
from etl.source.dutton.users_incr import source_dutton_users

ENVIRONMENT = os.getenv("AIRFLOW_ENV", "local").lower()
IS_PROD = ENVIRONMENT == "production"
SCHEDULE = "0 6-18 * * *" if IS_PROD else None

default_args = {
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

ETL_TASKS = {
    "boxes": source_dutton_boxes,
    "categories": source_dutton_categories,
    "colors": source_dutton_colors,
    "comments": source_dutton_comments,
    "customer_quote_details": source_dutton_customer_quote_details,
    "customers": source_dutton_customers,
    "price_list_product_variant": source_dutton_price_list_product_variant,
    "price_lists": source_dutton_price_lists,
    "product_images": source_dutton_product_images,
    "product_variants": source_dutton_product_variants,
    "products": source_dutton_products,
    "sizes": source_dutton_sizes,
    "stocks": source_dutton_stocks,
    "users": source_dutton_users,
}

with DAG(
    dag_id="source_dutton",
    default_args=default_args,
    description="Carga de ETLs de Dutton hacia Tatabi",
    schedule=SCHEDULE,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    is_paused_upon_creation=True,
    tags=["dutton"],
) as dag:

    tasks = {
        name: PythonOperator(
            task_id=name,
            python_callable=func
        )
        for name, func in ETL_TASKS.items()
    }

    tasks["boxes"] >> tasks["categories"] >> tasks["colors"] >> tasks["comments"]
    tasks["customer_quote_details"] >> tasks["customers"] >> tasks["price_list_product_variant"] >> tasks["price_lists"]
    tasks["product_images"] >> tasks["product_variants"] >> tasks["products"] >> tasks["sizes"]
    tasks["stocks"] >> tasks["users"]