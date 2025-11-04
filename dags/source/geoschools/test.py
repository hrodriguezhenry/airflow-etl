from airflow import DAG
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.operators.empty import EmptyOperator
from datetime import datetime


# --- Funciones de utilidad ---
def choose_branch(**kwargs):
    # Lógica de selección de rama
    return "branch_a"

def choose_branch_2(**kwargs):
    # Lógica del segundo branching
    return "branch_a2"

def print_task(task_name):
    print(f"Ejecutando tarea: {task_name}")


# --- Configuración base ---
default_args = {
    'start_date': datetime(2025, 1, 1),
    'retries': 1
}

with DAG(
    dag_id='example_double_branching_dag',
    default_args=default_args,
    schedule='@daily',
    catchup=False,
    tags=['example', 'branching']
) as dag:

    # ---------------- LOTE 1 ----------------
    start = EmptyOperator(task_id='start')

    branching = BranchPythonOperator(
        task_id='branching',
        python_callable=choose_branch
    )

    branch_a = PythonOperator(task_id='branch_a', python_callable=lambda: print_task("branch_a"))
    branch_b = PythonOperator(task_id='branch_b', python_callable=lambda: print_task("branch_b"))
    branch_c = PythonOperator(task_id='branch_c', python_callable=lambda: print_task("branch_c"))
    branch_d = PythonOperator(task_id='branch_d', python_callable=lambda: print_task("branch_d"))

    follow_branch_a = PythonOperator(task_id='follow_branch_a', python_callable=lambda: print_task("follow_branch_a"))
    follow_branch_b = PythonOperator(task_id='follow_branch_b', python_callable=lambda: print_task("follow_branch_b"))
    follow_branch_c = PythonOperator(task_id='follow_branch_c', python_callable=lambda: print_task("follow_branch_c"))
    follow_branch_d = PythonOperator(task_id='follow_branch_d', python_callable=lambda: print_task("follow_branch_d"))

    join = EmptyOperator(task_id='join', trigger_rule='none_failed_min_one_success')

    # Dependencias del primer bloque
    start >> branching
    branching >> branch_a >> follow_branch_a >> join
    branching >> branch_b >> follow_branch_b >> join
    branching >> branch_c >> follow_branch_c >> join
    branching >> branch_d >> follow_branch_d >> join

    # ---------------- LOTE 2 ----------------
    branching_2 = BranchPythonOperator(
        task_id='branching_2',
        python_callable=choose_branch_2
    )

    branch_a2 = PythonOperator(task_id='branch_a2', python_callable=lambda: print_task("branch_a2"))
    branch_b2 = PythonOperator(task_id='branch_b2', python_callable=lambda: print_task("branch_b2"))
    branch_c2 = PythonOperator(task_id='branch_c2', python_callable=lambda: print_task("branch_c2"))
    branch_d2 = PythonOperator(task_id='branch_d2', python_callable=lambda: print_task("branch_d2"))

    follow_a2 = PythonOperator(task_id='follow_a2', python_callable=lambda: print_task("follow_a2"))
    follow_b2 = PythonOperator(task_id='follow_b2', python_callable=lambda: print_task("follow_b2"))
    follow_c2 = PythonOperator(task_id='follow_c2', python_callable=lambda: print_task("follow_c2"))
    follow_d2 = PythonOperator(task_id='follow_d2', python_callable=lambda: print_task("follow_d2"))

    join_2 = EmptyOperator(task_id='join_2', trigger_rule='none_failed_min_one_success')
    end = EmptyOperator(task_id='end')

    # Dependencias del segundo bloque
    join >> branching_2
    branching_2 >> branch_a2 >> follow_a2 >> join_2
    branching_2 >> branch_b2 >> follow_b2 >> join_2
    branching_2 >> branch_c2 >> follow_c2 >> join_2
    branching_2 >> branch_d2 >> follow_d2 >> join_2
    join_2 >> end
