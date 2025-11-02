SELECT CHECKSUM(
		COALESCE(CONVERT(CHAR, ird.qr_id), 'N/A'),
		COALESCE(ird.cust_ord, 'N/A'),
		COALESCE(s.name, 'N/A'),
		COALESCE(l.name, 'N/A'),
		COALESCE(ist.name, 'N/A')
	) AS unique_id,

	ird.qr_id,
	ird.cust_ord,
	s.name AS stage,
	l.name AS production_line,
	ist.name AS inspection_line,
	ird.employee_name,
	ird.quantity,
	
	COUNT(
		IIF(ird.first_result IN ('pending', 'rejected') AND ird.second_result IS NULL, 1, NULL)
	) AS open_boxes_inspection,
	
	COUNT(
		IIF(ird.qr_id IS NOT NULL AND ird.first_result IS NULL, 1, NULL)
	) AS pending_boxes_inspection,
	
	COUNT(
		IIF(ird.first_result = 'approved' OR ird.second_result IN ('approved', 'rejected'), 1, NULL)
	) AS closed_boxes_inspection,
	
	'N' AS delete_row
	
FROM source_atomic_qis.inspection_station AS ist
INNER JOIN source_atomic_qis.inspection_stage AS ista
ON ist.stage_id = ista.id
AND ista.id IN (2, 3, 4, 8, 6)
INNER JOIN source_atomic.stage_system_inspection AS ssi
ON ist.atomic_stage_id = ssi.stage_id
INNER JOIN source_atomic.station_system AS ss
ON ist.atomic_line_id = ss.line_id
AND ssi.id = ss.stage_system_id
AND ss.status = 1

FULL JOIN (
	SELECT ISNULL(irt.qr_id, sp.qr_id) AS qr_id,
		ISNULL(irt.cust_ord, sp.cust_ord) AS cust_ord,
		irt.employee_name,
		ISNULL(irt.atomic_stage_id, sp.stage_id) AS stage_id,
		ISNULL(irt.atomic_line_id, sp.line_id) AS line_id,
		ISNULL(irt.quantity, sp.quantity) AS quantity,
		irt.first_inspection,
		irt.first_result,
		irt.first_last_close_at,
		irt.second_inspection,
		irt.second_result,
		irt.second_last_close_at
	FROM (
		SELECT ira.qr_id,
			ira.cust_ord,
			ira.employee_name,
			ira.atomic_stage_id,
			ira.atomic_line_id,
			ira.quantity,
			ira.first_inspection,
			ira.first_result,
			ira.first_last_close_at,
			irb.second_inspection,
			irb.second_result,
			irb.second_last_close_at
		FROM (
			SELECT ir.sfc_scan_qr_id AS qr_id,
				sq.cust_ord_hdr_number AS cust_ord,
				CONCAT(e.first_name, ' ', e.first_last_name) AS employee_name,
				ist.atomic_stage_id,
				ist.atomic_line_id,
				ir.station_id,
				ir.bundle_qty AS quantity,
				ir.no AS first_inspection,
				ir.result AS first_result,
				ir.last_close_at AS first_last_close_at
			FROM source_atomic_qis.inspection_revision AS ir
			INNER JOIN source_atomic_qis.inspection_station AS ist
			ON ir.station_id = ist.id
			INNER JOIN source_atomic_sfc.scan_qr AS sq
			ON ir.sfc_scan_qr_id = sq.id
			LEFT JOIN source_etalent.employee AS e
			ON ir.emp_cod = e.cod_employee
			WHERE CONVERT(date,  ir.created_at) = CONVERT(date, GETDATE())
			AND ist.stage_id IN (2, 3, 4, 8, 6)
			AND ir.no = 1
		) AS ira
		LEFT JOIN (
			SELECT ir.sfc_scan_qr_id AS qr_id,
				ir.station_id,
				ir.no AS second_inspection,
				ir.result AS second_result,
				ir.last_close_at AS second_last_close_at
			FROM source_atomic_qis.inspection_revision AS ir
			INNER JOIN source_atomic_qis.inspection_station AS ist
			ON ir.station_id = ist.id
			WHERE CONVERT(date,  ir.created_at) = CONVERT(date, GETDATE())
			AND ist.stage_id IN (2, 3, 4, 8, 6)
			AND ir.no = 2
		) AS irb
		ON ira.qr_id = irb.qr_id
		AND ira.station_id = irb.station_id
	) AS irt
	
	FULL JOIN (
		SELECT DISTINCT sfc_scan_qr_id AS qr_id,
			sq.cust_ord_hdr_number AS cust_ord,
			stp.line_id,
			
			CASE stp.stage_id
				WHEN 77 THEN 4
				WHEN 23 THEN 6
				ELSE stp.stage_id
			END AS stage_id,
			stp.quantity
			
		FROM source_atomic_sfc.scan_transact_production AS stp
		INNER JOIN source_atomic_sfc.scan_qr AS sq
		ON stp.sfc_scan_qr_id = sq.id
		WHERE CONVERT(date,  stp.created_at) = CONVERT(date, GETDATE())
		AND stp.operation_id IN (1691, 2185, 693, 2184, 1596, 2331, 2047, 2048, 2049, 1519, 419, 421, 427, 449, 580, 638, 659, 1448, 1621, 1868, 1967, 1993, 2032)
	) AS sp
	ON irt.qr_id = sp.qr_id
	AND irt.atomic_stage_id = sp.stage_id
	AND irt.atomic_line_id = sp.line_id
) AS ird
ON ist.atomic_stage_id = ird.stage_id
AND ist.atomic_line_id = ird.line_id

LEFT JOIN source_atomic.stage AS s
ON ISNULL(ist.atomic_stage_id, ird.stage_id) = s.id
LEFT JOIN source_atomic.line AS l
ON ISNULL(ist.atomic_line_id, ird.line_id) = l.id

GROUP BY ird.qr_id,
	ird.cust_ord,
	s.name,
	l.name,
	ist.name,
	ird.employee_name,
	ird.quantity