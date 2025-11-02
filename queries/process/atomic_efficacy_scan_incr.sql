SELECT w.day AS date,
	w.first_day_of_week,
	stp.id AS scan_transact_id,
	sq.cust_ord_hdr_number AS cust_ord,
	sq.style_id,
	sq.production_prefix,
	sq.id AS qr_id,
	stp.stage_id,
	s.name AS stage,
	stp.line_id,
	l.name AS line,
	stp.operation_id,
	op.operation,
	stp.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name) AS employee_name,
	IIF(stp.mark_type = 'single', 'Individual', 'Grupal') AS mark_type,
	stp.quantity,
	IIF(stp.substitute_group IS NULL, 1, 0) AS single_operation,
	stp.created_at AS scan_date	
FROM source_atomic_sfc.scan_transact_production AS stp
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON stp.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic.stage AS s
ON stp.stage_id = s.id
INNER JOIN source_atomic.line AS l
ON stp.line_id = l.id
INNER JOIN source_atomic_sfc.operation_production AS op
ON stp.operation_id = op.id
INNER JOIN source_accesorios.weeks AS w
ON stp.created_at_short = w.day
LEFT JOIN source_etalent.employee AS e
ON stp.cod_employee = e.cod_employee
WHERE sq.production_prefix != 'R'
AND sq.stage_id != 45
AND s.include_efficacy = 1
AND op.include_efficacy = 1
AND (stp.style_route_id IS NOT NULL OR stp.sam_specific_id IS NOT NULL)
AND CONCAT(sq.cust_ord_hdr_number, stp.stage_id) NOT IN  (
	SELECT CONCAT(sqa.cust_ord_hdr_number, 2)
	FROM source_atomic_sfc.scan_transact_production AS stpa
	INNER JOIN source_atomic_sfc.scan_qr AS sqa
	ON stpa.sfc_scan_qr_id = sqa.id
	WHERE stpa.stage_id = 24
	AND stpa.operation_id = 1205
	
	UNION ALL
	
	SELECT CONCAT(sqa.cust_ord_hdr_number, 3)
	FROM source_atomic_sfc.scan_transact_production AS stpa
	INNER JOIN source_atomic_sfc.scan_qr AS sqa
	ON stpa.sfc_scan_qr_id = sqa.id
	WHERE stpa.stage_id = 24
	AND stpa.operation_id = 1205
)
AND w.day >= CONVERT(date, GETDATE() -9)