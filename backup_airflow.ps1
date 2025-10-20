# Ruta base del proyecto
$projectPath = "C:\Users\hrodr\Documents\airflow_docker"
$backupPath = "C:\airflow_backups\$(Get-Date -Format yyyy-MM-dd)"

# Crear carpeta de respaldo con fecha
New-Item -ItemType Directory -Force -Path $backupPath

# 1. Respaldo de DAGs, logs y scripts
Copy-Item "$projectPath\dags" "$backupPath\dags" -Recurse
Copy-Item "$projectPath\logs" "$backupPath\logs" -Recurse
Copy-Item "$projectPath\etl" "$backupPath\etl" -Recurse
Copy-Item "$projectPath\docker-compose.yml" "$backupPath"

# 2. Exportar base de datos de metadatos de Airflow (Postgres)
docker exec -t airflow-postgres pg_dump -U airflow airflow > "$backupPath\airflow_metadata.sql"

Write-Host "Respaldo completado en $backupPath"