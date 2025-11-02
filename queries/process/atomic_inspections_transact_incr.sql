-- PROCESS_INSPECTIONS_TRANSACT
-- Update 2024-09-25

SELECT DISTINCT w.year AS inspection_year,
	w.week AS inspection_week,
	CONVERT(date, ir.last_close_at) AS inspection_date,
	stpa.id AS scan_transact_id,
	ir.sfc_scan_qr_id AS qr_id,
	stpa.quantity AS full_inspection,
	w.last_day_of_week
FROM source_atomic_qis.inspection_revision AS ir
INNER JOIN source_atomic_sfc.scan_transact_production AS stpa 
ON ir.sfc_scan_qr_id = stpa.sfc_scan_qr_id
AND ir.last_close_at >= stpa.created_at
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, ir.last_close_at) = w.day
WHERE w.day >= CONVERT(date, GETDATE() - 14)