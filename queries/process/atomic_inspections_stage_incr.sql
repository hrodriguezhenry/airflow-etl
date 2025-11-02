-- PROCESS_ATOMIC_INSPECTIONS_STAGE
-- Update 2024-09-25

-- Consulta que me trae la cantidad de unidades inspeccionadas por etapa,
-- siendo esta prorrateado por la cantidad de empleados tanto por dia como por
-- semana.
SELECT isd.inspection_year,
	isd.inspection_week,
	isd.inspection_date,
	isd.stage_id,
	CONVERT(DECIMAL (12, 6), isd.daily_qty_full_inspections_stage)
		/ iscd.cnt_employee AS daily_qty_full_inspections_stage,
	
	CONVERT(DECIMAL (12, 6), isd.daily_qty_first_inspections_stage)
		/ iscd.cnt_employee AS daily_qty_first_inspections_stage,
		
	CONVERT(DECIMAL (12, 6), isw.weekly_qty_full_inspections_stage)
		/ iscw.cnt_employee AS weekly_qty_full_inspections_stage,
	
	CONVERT(DECIMAL (12, 6), isw.weekly_qty_first_inspections_stage)
		/ iscw.cnt_employee AS weekly_qty_first_inspections_stage,
	isd.last_day_of_week
	
-- Consulta "isd" que me trae la cantidad de unidades diarias inspeccionadas 
-- por etapa.
FROM (
	SELECT issd.inspection_year,
		issd.inspection_week,
		issd.inspection_date,
		issd.stage_id,
		SUM(issd.full_inspection) AS daily_qty_full_inspections_stage,
		SUM(issd.first_inspection) AS daily_qty_first_inspections_stage,
		issd.last_day_of_week
		
	-- Consulta "isd" que me trae todas las inspecciones diarias de calidad
    -- por etapa, realizadas por cada bulto escaneado en producción.
	FROM (
		SELECT DISTINCT aita.inspection_year,
			aita.inspection_week,
			aita.inspection_date,
			stp.stage_id,
			aita.qr_id,
			aita.full_inspection,
			aita.first_inspection,
			aita.last_day_of_week
		FROM process.atomic_inspections_transact_detail AS aita
		INNER JOIN source_atomic_sfc.scan_transact_production AS stp
		ON aita.scan_transact_id = stp.id
		WHERE aita.inspection_date >= CONVERT(date, GETDATE() -14)
	) AS issd
	
	GROUP BY issd.inspection_year,
		issd.inspection_week,
		issd.inspection_date,
		issd.stage_id,
		issd.last_day_of_week
) AS isd

-- Consulta "iscd" que me trae la cantidad de empleados por fecha que estuvieron
-- involucrados en una etapa inspeccionada.
INNER JOIN (
	SELECT aiea.inspection_date,
		aiea.stage_id,
		COUNT(aiea.cod_employee) AS cnt_employee
	FROM process.atomic_inspections_employee AS aiea
	WHERE aiea.inspection_date >= CONVERT(date, GETDATE() -14)
	GROUP BY aiea.inspection_date,
		aiea.stage_id
) AS iscd
ON isd.inspection_date = iscd.inspection_date
AND isd.stage_id = iscd.stage_id

-- Consulta "isw" que me trae la cantidad de unidades semanales
-- inspeccionadas por etapa.
INNER JOIN (
	SELECT issw.stage_id,
		SUM(issw.full_inspection) AS weekly_qty_full_inspections_stage,
		SUM(issw.first_inspection) AS weekly_qty_first_inspections_stage,
		issw.last_day_of_week
		
	-- Consulta "islw" que me trae todas las inspecciones semanales de calidad
    -- por etapa, realizadas por cada bulto escaneado en producción.
	FROM (
		SELECT DISTINCT stp.stage_id,
			aitw.qr_id,
			aitw.full_inspection,
			aitw.first_inspection,
			aitw.last_day_of_week
		
		-- Consulta "aitw" que me trae todas las inspecciones semanales de calidad
    	-- realizadas por cada bulto escaneado en producción.
		FROM (
			SELECT DISTINCT aitb.scan_transact_id,
				aitb.qr_id,
				aitb.full_inspection,
				aitb.first_inspection,
				aitb.last_day_of_week
			FROM process.atomic_inspections_transact_detail AS aitb
			WHERE aitb.last_day_of_week >= CONVERT(date, GETDATE() -14)
		) AS aitw
		
		INNER JOIN source_atomic_sfc.scan_transact_production AS stp
		ON aitw.scan_transact_id = stp.id
	) AS issw

	GROUP BY issw.stage_id,
		issw.last_day_of_week
) AS isw
ON isd.last_day_of_week = isw.last_day_of_week
AND isd.stage_id = isw.stage_id

-- Consulta "iscw" que me trae la cantidad de empleados por semana que estuvieron
-- involucrados en una etapa inspeccionada.
INNER JOIN (
	SELECT aieb.stage_id,
		COUNT(aieb.cod_employee) AS cnt_employee,
		aieb.last_day_of_week
	FROM process.atomic_inspections_employee AS aieb
	WHERE aieb.last_day_of_week >= CONVERT(date, GETDATE() -14)
	GROUP BY aieb.stage_id,
		aieb.last_day_of_week
) AS iscw
ON isw.last_day_of_week = iscw.last_day_of_week
AND isw.stage_id = iscw.stage_id