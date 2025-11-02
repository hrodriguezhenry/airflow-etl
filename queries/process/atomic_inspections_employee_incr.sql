-- PROCESS_ATOMIC_INSPECTIONS_EMPLOYEE
-- Update 2024-09-2

-- Consulta que me trae la cantidad de unidades inspeccionadas por empleado,
-- incluyendo la cantidad de defectos y desperdicio asignado.
SELECT ide.inspection_year,
	ide.inspection_week,
	ide.inspection_date,
	ide.cod_employee,
	ide.stage_id,
	ide.line_id,
	ide.operation_id,
	ide.daily_qty_full_inspections_employee,
	ide.daily_qty_first_inspections_employee,
	CONVERT(DECIMAL (12, 6), icslow.weekly_qty_full_inspections_employee)
		/ icsloc.cnt_days  AS weekly_qty_full_inspections_employee,
	CONVERT(DECIMAL (12, 6), icslow.weekly_qty_first_inspections_employee)
		/ icsloc.cnt_days  AS weekly_qty_first_inspections_employee,
    ide.rejected_qty_employee,
    ide.waste_qty_employee,
    ide.last_day_of_week

-- Consulta "ide" que me trae la cantidad de unidades diarias inspeccionadas 
-- por empleado, incluyendo la cantidad de unidades rechazadas y desperdiciadas.
FROM (
	SELECT ait.inspection_year,
		ait.inspection_week,
		ait.inspection_date,
		m.cod_employee,
		stp.stage_id,
		stp.line_id,
		stp.operation_id,
		SUM(ait.full_inspection) AS daily_qty_full_inspections_employee,
		SUM(ait.first_inspection) AS daily_qty_first_inspections_employee,
		SUM(ait.rejected_qty) AS rejected_qty_employee,
		SUM(ait.waste_qty) AS waste_qty_employee,
		ait.last_day_of_week
	FROM process.atomic_inspections_transact_detail AS ait
	INNER JOIN source_atomic_sfc.scan_transact_production AS stp
	ON ait.scan_transact_id = stp.id
	INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
	ON stp.group_mark_id = gmr.group_mark_id
	INNER JOIN source_atomic_sfc.mark AS m
	ON gmr.mark_id = m.id
	WHERE ait.inspection_date >= CONVERT(date, GETDATE() - 14)
	GROUP BY ait.inspection_year,
		ait.inspection_week,
		ait.inspection_date,
		m.cod_employee,
		stp.stage_id,
		stp.line_id,
		stp.operation_id,
		ait.last_day_of_week
) AS ide

-- Consulta "icslow" que me trae la cantidad de unidades semanales
-- inspeccionadas por empleado.
INNER JOIN (
	SELECT m.cod_employee,
		stp.stage_id,
		stp.line_id,
		stp.operation_id,
		SUM(aitw.full_inspection) AS weekly_qty_full_inspections_employee,
		SUM(aitw.first_inspection) AS weekly_qty_first_inspections_employee,
		aitw.last_day_of_week

	-- Consulta "aitw" que me trae todas las inspecciones semanales de calidad 
    -- realizadas por cada bulto escaneado en producción.
	FROM (
		SELECT DISTINCT aita.scan_transact_id,
			aita.qr_id,
			aita.full_inspection,
			aita.first_inspection,
			aita.last_day_of_week
		FROM process.atomic_inspections_transact_detail AS aita
		WHERE aita.last_day_of_week >= CONVERT(date, GETDATE() - 14)
	) AS aitw
	
	INNER JOIN source_atomic_sfc.scan_transact_production AS stp
	ON aitw.scan_transact_id = stp.id
	INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
	ON stp.group_mark_id = gmr.group_mark_id
	INNER JOIN source_atomic_sfc.mark AS m
	ON gmr.mark_id = m.id
	GROUP BY m.cod_employee,
		stp.stage_id,
		stp.line_id,
		stp.operation_id,
		aitw.last_day_of_week
) AS icslow
ON ide.last_day_of_week = icslow.last_day_of_week
AND ide.cod_employee = icslow.cod_employee
AND ide.stage_id = icslow.stage_id
AND ide.line_id = icslow.line_id
AND ide.operation_id = icslow.operation_id

-- Consulta "icsloc" que me trae el conteo de dias en los que estuvo 
-- involucrado un empleado en una linea, etapa y operación distinta.
INNER JOIN (
	SELECT icslo.cod_employee,
		icslo.stage_id,
		icslo.line_id,
		icslo.operation_id,
		COUNT(icslo.inspection_date) AS cnt_days,
    	icslo.last_day_of_week
    	
    -- Consulta "icslo" que me trae por dia una fila 
    -- distinta de empleado, etapa, linea y operación.
	FROM (
		SELECT DISTINCT ait.inspection_date,
			m.cod_employee,
			stp.stage_id,
			stp.line_id,
			stp.operation_id,
			ait.last_day_of_week
		FROM process.atomic_inspections_transact_detail AS ait
		INNER JOIN source_atomic_sfc.scan_transact_production AS stp
		ON ait.scan_transact_id = stp.id
		INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
		ON stp.group_mark_id = gmr.group_mark_id
		INNER JOIN source_atomic_sfc.mark AS m
		ON gmr.mark_id = m.id
		WHERE ait.last_day_of_week >= CONVERT(date, GETDATE() - 14)
	) AS icslo
	
	GROUP BY icslo.cod_employee,
		icslo.stage_id,
		icslo.line_id,
		icslo.operation_id,
		icslo.last_day_of_week
) AS icsloc
ON ide.last_day_of_week = icsloc.last_day_of_week
AND ide.cod_employee = icsloc.cod_employee
AND ide.stage_id = icsloc.stage_id
AND ide.line_id = icsloc.line_id
AND ide.operation_id = icsloc.operation_id