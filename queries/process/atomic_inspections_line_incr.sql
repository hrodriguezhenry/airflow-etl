-- PROCESS_ATOMIC_INSPECTIONS_LINE
-- Update 2024-09-25

-- Consulta que me trae la cantidad de unidades inspeccionadas por línea,
-- siendo esta prorrateado por la cantidad de empleados tanto por dia como por
-- semana.
SELECT ild.inspection_year,
	ild.inspection_week,
	ild.inspection_date,
	ild.stage_id,
	ild.line_id,
	CONVERT(DECIMAL (12, 6), ild.daily_qty_full_inspections_line)
		/ ilcd.cnt_employee AS daily_qty_full_inspections_line,
	
	CONVERT(DECIMAL (12, 6), ild.daily_qty_first_inspections_line)
		/ ilcd.cnt_employee AS daily_qty_first_inspections_line,
		
	CONVERT(DECIMAL (12, 6), ilw.weekly_qty_full_inspections_line)
		/ ilcw.cnt_employee AS weekly_qty_full_inspections_line,
		
	CONVERT(DECIMAL (12, 6), ilw.weekly_qty_first_inspections_line)
		/ ilcw.cnt_employee AS weekly_qty_first_inspections_line,
	ild.last_day_of_week
	
-- Consulta "ild" que me trae la cantidad de unidades diarias inspeccionadas 
-- por línea.
FROM (
	SELECT isld.inspection_year,
		isld.inspection_week,
		isld.inspection_date,
		isld.stage_id,
		isld.line_id,
		SUM(isld.full_inspection) AS daily_qty_full_inspections_line,
		SUM(isld.first_inspection) AS daily_qty_first_inspections_line,
		isld.last_day_of_week
		
	-- Consulta "isld" que me trae todas las inspecciones diarias de calidad
    -- por línea, realizadas por cada bulto escaneado en producción.
	FROM (
		SELECT DISTINCT aita.inspection_year,
			aita.inspection_week,
			aita.inspection_date,
			stp.stage_id,
			stp.line_id,
			aita.qr_id,
			aita.full_inspection,
			aita.first_inspection,
			aita.last_day_of_week
		FROM process.atomic_inspections_transact_detail AS aita
		INNER JOIN source_atomic_sfc.scan_transact_production AS stp
		ON aita.scan_transact_id = stp.id
		WHERE aita.inspection_date >= CONVERT(date, GETDATE() -14)
	) AS isld
	
	GROUP BY isld.inspection_year,
		isld.inspection_week,
		isld.inspection_date,
		isld.stage_id,
		isld.line_id,
		isld.last_day_of_week
) AS ild

-- Consulta "ilcd" que me trae la cantidad de empleados por fecha que estuvieron
-- involucrados en una línea inspeccionada.
INNER JOIN (
	SELECT aiea.inspection_date,
		aiea.stage_id,
		aiea.line_id,
		COUNT(aiea.cod_employee) AS cnt_employee
	FROM process.atomic_inspections_employee AS aiea
	WHERE aiea.inspection_date >= CONVERT(date, GETDATE() -14)
	GROUP BY aiea.inspection_date,
		aiea.stage_id,
		aiea.line_id
) AS ilcd
ON ild.inspection_date = ilcd.inspection_date
AND ild.stage_id = ilcd.stage_id
AND ild.line_id = ilcd.line_id

-- Consulta "ilw" que me trae la cantidad de unidades semanales
-- inspeccionadas por línea.
INNER JOIN (
	SELECT islw.stage_id,
		islw.line_id,
		SUM(islw.full_inspection) AS weekly_qty_full_inspections_line,
		SUM(islw.first_inspection) AS weekly_qty_first_inspections_line,
		islw.last_day_of_week
		
	-- Consulta "islw" que me trae todas las inspecciones semanales de calidad
    -- por línea, realizadas por cada bulto escaneado en producción.
	FROM (
		SELECT DISTINCT stp.stage_id,
			stp.line_id,
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
	) AS islw

	GROUP BY islw.stage_id,
		islw.line_id,
		islw.last_day_of_week
) AS ilw
ON ild.last_day_of_week = ilw.last_day_of_week
AND ild.stage_id = ilw.stage_id
AND ild.line_id = ilw.line_id

-- Consulta "ilcw" que me trae la cantidad de empleados por semana que estuvieron
-- involucrados en una línea inspeccionada.
INNER JOIN (
	SELECT aieb.stage_id,
		aieb.line_id,
		COUNT(aieb.cod_employee) AS cnt_employee,
		aieb.last_day_of_week
	FROM process.atomic_inspections_employee AS aieb
	WHERE aieb.last_day_of_week >= CONVERT(date, GETDATE() -14)
	GROUP BY aieb.stage_id,
		aieb.line_id,
		aieb.last_day_of_week
) AS ilcw
ON ilw.last_day_of_week = ilcw.last_day_of_week
AND ilw.stage_id = ilcw.stage_id
AND ilw.line_id = ilcw.line_id