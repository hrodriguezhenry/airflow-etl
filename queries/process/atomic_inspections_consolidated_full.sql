-- PROCESS_ATOMIC_INSPECTIONS_CONSOLIDATED
-- Update 2024-09-25

-- Consulta que me trae el universo de inspecciones por empleado,
-- operación, linea y etapa, traendo la cantidad de unidades
-- rechazadas y desperdiciadas, siendo estas asignables o no a 
-- un operario u operación.
SELECT aic.inspection_year,
	aic.inspection_week,
	aic.inspection_date,
	aic.cod_employee,
	aic.stage_id,
	aic.line_id,
	aic.operation_id,
	aic.daily_qty_full_inspections_employee,
	aic.daily_qty_first_inspections_employee,
	aic.weekly_qty_full_inspections_employee,
	aic.weekly_qty_first_inspections_employee,
    CONVERT(DECIMAL (12, 6), aic.rejected_qty_employee) AS rejected_qty_employee,
    CONVERT(DECIMAL (12, 6), aic.waste_qty_employee) AS waste_qty_employee,
	aic.daily_qty_full_inspections_operation,
	aic.daily_qty_first_inspections_operation,
	aic.weekly_qty_full_inspections_operation,
	aic.weekly_qty_first_inspections_operation,
	CONVERT(DECIMAL (12, 6), aic.rejected_qty_operation) AS rejected_qty_operation,
    CONVERT(DECIMAL (12, 6), aic.waste_qty_operation) AS waste_qty_operation,
	aic.daily_qty_full_inspections_line,
	aic.daily_qty_first_inspections_line,
	aic.weekly_qty_full_inspections_line,
	aic.weekly_qty_first_inspections_line,
	aic.daily_qty_full_inspections_stage,
	aic.daily_qty_first_inspections_stage,
	aic.weekly_qty_full_inspections_stage,
	aic.weekly_qty_first_inspections_stage

FROM (
	-- Consulta que me trae la cantidad de unidades inspeccionadas por empleado,
	-- operación, línea y etapa, incluyendo la cantidad de defectos y desperdicio asignado.
	SELECT aie.inspection_year,
		aie.inspection_week,
		aie.inspection_date,
		aie.cod_employee,
		aie.stage_id,
		aie.line_id,
		aie.operation_id,
		aie.daily_qty_full_inspections_employee,
		aie.daily_qty_first_inspections_employee,
		aie.weekly_qty_full_inspections_employee,
		aie.weekly_qty_first_inspections_employee,
	    aie.rejected_qty_employee,
	    aie.waste_qty_employee,
		aio.daily_qty_full_inspections_operation,
		aio.daily_qty_first_inspections_operation,
		aio.weekly_qty_full_inspections_operation,
		aio.weekly_qty_first_inspections_operation,
		aio.rejected_qty_operation,
		aio.waste_qty_operation,
		ail.daily_qty_full_inspections_line,
		ail.daily_qty_first_inspections_line,
		ail.weekly_qty_full_inspections_line,
		ail.weekly_qty_first_inspections_line,
		ais.daily_qty_full_inspections_stage,
		ais.daily_qty_first_inspections_stage,
		ais.weekly_qty_full_inspections_stage,
		ais.weekly_qty_first_inspections_stage
	FROM process.atomic_inspections_employee AS aie
	INNER JOIN process.atomic_inspections_operation_detail AS aio
	ON aie.inspection_date = aio.inspection_date
	AND aie.stage_id = aio.stage_id
	AND aie.line_id = aio.line_id
	AND aie.operation_id = aio.operation_id
	INNER JOIN process.atomic_inspections_line AS ail
	ON aie.inspection_date = ail.inspection_date
	AND aie.stage_id = ail.stage_id
	AND aie.line_id = ail.line_id
	INNER JOIN process.atomic_inspections_stage AS ais
	ON aie.inspection_date = ais.inspection_date
	AND aie.stage_id = ais.stage_id
	
	UNION ALL
	-- Consulta que me trae la cantidad de unidades rechazadas y desperdiciadas
	-- que no fueron asignadas a un empleado
	SELECT ISNULL(isqr.inspection_year, isqw.inspection_year) AS inspection_year,
		ISNULL(isqr.inspection_week, isqw.inspection_week) AS inspection_week,
		ISNULL(isqr.inspection_date, isqw.inspection_date) AS inspection_date,
		NULL AS cod_employee,
		ISNULL(isqr.stage_id, isqw.stage_id) AS stage_id,
		ISNULL(isqr.line_id, isqw.line_id) AS line_id,
		NULL AS operation_id,
		NULL AS daily_qty_full_inspections_employee,
		NULL AS daily_qty_first_inspections_employee,
		NULL AS weekly_qty_full_inspections_employee,
		NULL AS weekly_qty_first_inspections_employee,
		CONVERT(DECIMAL (12, 6), ISNULL(isqr.rejected_qty, 0)) AS rejected_qty_employee,
		CONVERT(DECIMAL (12, 6), ISNULL(isqw.waste_qty, 0)) AS waste_qty_employee,
		NULL AS daily_qty_full_inspections_operation,
		NULL AS daily_qty_first_inspections_operation,
		NULL AS weekly_qty_full_inspections_operation,
		NULL AS weekly_qty_first_inspections_operation,
		CONVERT(DECIMAL (12, 6), ISNULL(isqr.rejected_qty, 0)) AS rejected_qty_operation,
		CONVERT(DECIMAL (12, 6), ISNULL(isqw.waste_qty, 0)) AS waste_qty_operation,
		NULL AS daily_qty_full_inspections_line,
		NULL AS daily_qty_first_inspections_line,
		NULL AS weekly_qty_full_inspections_line,
		NULL AS weekly_qty_first_inspections_line,
		NULL AS daily_qty_full_inspections_stage,
		NULL AS daily_qty_first_inspections_stage,
		NULL AS weekly_qty_full_inspections_stage,
		NULL AS weekly_qty_first_inspections_stage
	
	-- Consulta "isqr" que me trae las unidades rechazadas que no 
	-- fueron asignadas a un empleado.
	FROM (
		SELECT aqi.inspection_year,
			aqi.inspection_week,
			aqi.inspection_date,
			aqi.qr_id,
			aqi.station_id,
			"is".atomic_stage_id AS stage_id,
			"is".atomic_line_id AS line_id,
			SUM(aqi.defect_qty) AS rejected_qty
		FROM dwh.atomic_qis_inspections AS aqi
		INNER JOIN source_atomic_qis.inspection_station AS "is"
		ON aqi.station_id = "is".id
		WHERE aqi.inspection_number = 1
		AND aqi.result = 'rejected'
		AND aqi.group_mark_id IS NULL
		GROUP BY aqi.inspection_year,
			aqi.inspection_week,
			aqi.inspection_date,
			aqi.qr_id,
			aqi.station_id,
			"is".atomic_stage_id,
			"is".atomic_line_id
	) AS isqr
	
	-- Consulta "isqw" que me trae las unidades desperdiciadas que no 
	-- fueron asignadas a un empleado.
	FULL JOIN (
		SELECT aqi.inspection_year,
			aqi.inspection_week,
			aqi.inspection_date,
			aqi.qr_id,
			aqi.station_id,
			"is".atomic_stage_id AS stage_id,
			"is".atomic_line_id AS line_id,
			SUM(aqi.defect_qty) AS waste_qty
		FROM dwh.atomic_qis_inspections AS aqi
		INNER JOIN source_atomic_qis.inspection_station AS "is"
		ON aqi.station_id = "is".id
		WHERE aqi.inspection_number = 2
		AND aqi.result = 'rejected'
		AND aqi.group_mark_id IS NULL
		GROUP BY aqi.inspection_year,
			aqi.inspection_week,
			aqi.inspection_date,
			aqi.qr_id,
			aqi.station_id,
			"is".atomic_stage_id,
			"is".atomic_line_id
	) AS isqw
	ON isqr.inspection_date = isqw.inspection_date
	AND isqr.station_id = isqw.station_id
	AND isqr.qr_id = isqw.qr_id
) AS aic