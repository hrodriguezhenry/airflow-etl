-- PROCESS_ATOMIC_INSPECTIONS_OPERATION
-- Update 2024-09-25

SELECT ait.inspection_year,
	ait.inspection_week,
	ait.inspection_date,
	stp.stage_id,
	stp.line_id,
	stp.operation_id,
	SUM(ait.full_inspection) AS daily_qty_full_inspections_operation,
	SUM(ait.first_inspection) AS daily_qty_first_inspections_operation,
	SUM(ait.rejected_qty) AS rejected_qty_operation,
	SUM(ait.waste_qty) AS waste_qty_operation,
	w.last_day_of_week
FROM process.atomic_inspections_transact_detail AS ait
INNER JOIN source_atomic_sfc.scan_transact_production AS stp
ON ait.scan_transact_id = stp.id
INNER JOIN source_accesorios.weeks AS w
ON ait.inspection_date = w.day
WHERE ait.inspection_date >= CONVERT(date, GETDATE() - 14)
GROUP BY ait.inspection_year,
	ait.inspection_week,
	ait.inspection_date,
	stp.stage_id,
	stp.line_id,
	stp.operation_id,
	w.last_day_of_week