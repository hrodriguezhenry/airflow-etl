-- PROCESS_ATOMIC_INSPECTIONS_OPERATION_DETAIL
-- Update 2024-09-25

-- Consulta que me trae la cantidad de unidades inspeccionadas por operación,
-- siendo esta prorrateado por la cantidad de empleados tanto por dia como por
-- semana, incluyendo la cantidad de defectos y desperdicio asignado. 
SELECT iod.inspection_year,
	iod.inspection_week,
	iod.inspection_date,
	iod.stage_id,
	iod.line_id,
	iod.operation_id,
	
	CONVERT(DECIMAL (12, 6), iod.daily_qty_full_inspections_operation)
		/ iocd.cnt_employee AS daily_qty_full_inspections_operation,
		
	CONVERT(DECIMAL (12, 6), iod.daily_qty_first_inspections_operation)
		/ iocd.cnt_employee AS daily_qty_first_inspections_operation,
		
	CONVERT(DECIMAL (12, 6), iow.weekly_qty_full_inspections_operation)
		/ iocw.cnt_employee AS weekly_qty_full_inspections_operation,
		
	CONVERT(DECIMAL (12, 6), iow.weekly_qty_first_inspections_operation)
		/ iocw.cnt_employee AS weekly_qty_first_inspections_operation,
		
	CONVERT(DECIMAL (12, 6), iod.rejected_qty_operation)
		/ iocd.cnt_employee AS rejected_qty_operation,
		
	CONVERT(DECIMAL (12, 6), iod.waste_qty_operation)
		/ iocd.cnt_employee AS waste_qty_operation,
	iod.last_day_of_week
	
-- Consulta "iod" que me trae la cantidad de unidades diarias inspeccionadas 
-- por operación, incluyendo la cantidad de unidades rechazadas y desperdiciadas.
FROM process.atomic_inspections_operation AS iod

-- Consulta "iocd" que me trae la cantidad de empleados por fecha que estuvieron
-- involucrados en una operación inspeccionada.
INNER JOIN (
	SELECT aiea.inspection_date,
		aiea.stage_id,
		aiea.line_id,
		aiea.operation_id,
		COUNT(aiea.cod_employee) AS cnt_employee
	FROM process.atomic_inspections_employee AS aiea
	GROUP BY aiea.inspection_date,
		aiea.stage_id,
		aiea.line_id,
		aiea.operation_id
) AS iocd
ON iod.inspection_date = iocd.inspection_date
AND iod.stage_id = iocd.stage_id
AND iod.line_id = iocd.line_id
AND iod.operation_id = iocd.operation_id

-- Consulta "iow" que me trae la cantidad de unidades semanales
-- inspeccionadas por operación.
INNER JOIN process.atomic_inspections_operation_transact AS iow
ON iod.last_day_of_week = iow.last_day_of_week
AND iod.stage_id = iow.stage_id
AND iod.line_id = iow.line_id
AND iod.operation_id = iow.operation_id

-- Consulta "iocw" que me trae la cantidad de empleados por semana que estuvieron
-- involucrados en una operación inspeccionada
INNER JOIN (
	SELECT aieb.stage_id,
		aieb.line_id,
		aieb.operation_id,
		COUNT(aieb.cod_employee) AS cnt_employee,
		aieb.last_day_of_week
	FROM process.atomic_inspections_employee AS aieb
	GROUP BY aieb.stage_id,
		aieb.line_id,
		aieb.operation_id,
		aieb.last_day_of_week
) AS iocw
ON iow.last_day_of_week = iocw.last_day_of_week
AND iow.stage_id = iocw.stage_id
AND iow.line_id = iocw.line_id
AND iow.operation_id = iocw.operation_id