-- PROCESS_ATOMIC_INSPECTIONS_OPERATION_TRANSACT
-- Update 2024-06-03

SELECT stp.stage_id,
	stp.line_id,
	stp.operation_id,
	SUM(aitw.full_inspection) AS weekly_qty_full_inspections_operation,
	SUM(aitw.first_inspection) AS weekly_qty_first_inspections_operation,
	aitw.last_day_of_week

-- Consulta "aitw" que me trae todas las inspecciones semanales de calidad
-- realizadas por cada bulto escaneado en producción.
FROM (
	SELECT DISTINCT aita.scan_transact_id,
		aita.qr_id,
		aita.full_inspection,
		aita.first_inspection,
		w.last_day_of_week
	FROM process.atomic_inspections_transact_detail AS aita
	INNER JOIN source_accesorios.weeks AS w
	ON aita.inspection_date = w.day
	WHERE w.last_day_of_week >= CONVERT(date, GETDATE() - 14)
) AS aitw

INNER JOIN source_atomic_sfc.scan_transact_production AS stp
ON aitw.scan_transact_id = stp.id
GROUP BY stp.stage_id,
	stp.line_id,
	stp.operation_id,
	aitw.last_day_of_week