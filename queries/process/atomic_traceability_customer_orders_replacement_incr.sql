WITH customer_orders AS (
	SELECT sq.cust_ord_hdr_number AS cust_ord,
		sq.style_id,
		sq.id AS qr_id,
		MAX(stp.created_at) AS created_at
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	AND sq.production_prefix = 'T'
	AND sq.stage_id = 6
	INNER JOIN source_proaktiv.cust_ord_hdr AS coh
	ON sq.cust_ord_hdr_number = coh.cust_ord_hdr_number
	AND coh.cust_ord_hdr_status = 'O'
	AND coh.is_reposition_flag = 'Y'
	GROUP BY sq.cust_ord_hdr_number,
		sq.style_id,
		sq.id
)

SELECT co.cust_ord,
	co.style_id,
	co.qr_id,
	qe.employee_name,
	qe.operation,
	qe.date,
	sqd.quantity,
	sd.sz_dim_det_size AS size,
	'N' AS delete_row
FROM customer_orders AS co
INNER JOIN source_atomic_sfc.scan_qr_detail AS sqd
ON co.qr_id = sqd.scan_qr_id
INNER JOIN source_atomic_sfc.size_detail AS sd
ON sqd.sz_dim_det_number = sd.sz_dim_det_number

LEFT JOIN (
	SELECT ISNULL(qep.qr_id, qei.qr_id) AS qr_id,
		
		CASE
			WHEN qep.created_at IS NULL THEN qei.employee_name
			WHEN qei.created_at IS NULL THEN qep.employee_name
			WHEN qep.created_at > qei.created_at THEN qep.employee_name
			WHEN qei.created_at >= qep.created_at THEN qei.employee_name
		END AS employee_name,
		
		CASE
			WHEN qep.created_at IS NULL THEN qei.operation
			WHEN qei.created_at IS NULL THEN qep.operation
			WHEN qep.created_at > qei.created_at THEN qep.operation
			WHEN qei.created_at >= qep.created_at THEN qei.operation
		END AS operation,

		CASE
			WHEN qep.created_at IS NULL THEN CONVERT(date, qei.created_at)
			WHEN qei.created_at IS NULL THEN CONVERT(date, qep.created_at)
			WHEN qep.created_at > qei.created_at THEN CONVERT(date, qep.created_at)
			WHEN qei.created_at >= qep.created_at THEN CONVERT(date, qei.created_at)
		END AS date
		
	FROM (
		SELECT stpa.sfc_scan_qr_id AS qr_id,
			STRING_AGG(CONCAT(e.cod_employee, ' - ' , e.first_name, ' ', e.first_last_name), ' ,') AS employee_name,
			STRING_AGG(op.operation, ' ,') AS operation,
			stpa.created_at
		FROM customer_orders AS qc
		INNER JOIN source_atomic_sfc.scan_transact_production stpa
		ON qc.qr_id = stpa.sfc_scan_qr_id
		AND qc.created_at = stpa.created_at
		LEFT JOIN source_atomic_sfc.group_mark_ref AS gmr
		ON stpa.group_mark_id = gmr.group_mark_id
		LEFT JOIN source_atomic_sfc.mark AS m
		ON gmr.mark_id = m.id
		LEFT JOIN source_atomic_sfc.operation_production AS op
		ON stpa.operation_id = op.id
		LEFT JOIN source_etalent.employee AS e
		ON m.cod_employee = e.cod_employee
		GROUP BY stpa.sfc_scan_qr_id,
			stpa.created_at
	) AS qep
		
		
	FULL JOIN (
		SELECT ira.sfc_scan_qr_id AS qr_id,
			CONCAT(ISNULL(ira.emp_cod, ''), ' - ', u.usr_name) AS employee_name,
			'Calidad Cuepos' AS operation,
			ira.created_at
			
		FROM (
			SELECT ir.sfc_scan_qr_id AS qr_id,
				MAX(ir.created_at) AS created_at
			FROM source_atomic_qis.inspection_revision AS ir
			INNER JOIN source_atomic_qis.inspection_station AS ist
			ON ir.station_id = ist.id
			WHERE ist.stage_id = 4
			AND EXISTS (
				SELECT 1
				FROM customer_orders AS cob
				WHERE cob.qr_id = ir.sfc_scan_qr_id 
			)
				GROUP BY ir.sfc_scan_qr_id
		) AS qsi
		INNER JOIN source_atomic_qis.inspection_revision AS ira
		ON qsi.qr_id = ira.sfc_scan_qr_id
		AND qsi.created_at = ira.created_at
		INNER JOIN source_atomic_qis.inspection_station AS ista
		ON ira.station_id = ista.id
		INNER JOIN source_proaktiv.users AS u
		ON ira.created_by = u.usr_number
	) AS qei
	ON qep.qr_id = qei.qr_id
) AS qe
ON co.qr_id = qe.qr_id