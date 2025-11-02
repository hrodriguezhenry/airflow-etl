-- DWH_ATOMIC_REPLCACEMENT_EFFICACY
-- Update 2023-08-14

SELECT qros.qr_id,
	qros.cust_ord,
	qros.style_id,
	qros.stage_id,
	s.name AS stage,
	stpa.line_id,
	li.name AS line,
	qros.operation_id,
	op.operation,
	stpa.group_mark_id,
	stpa.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name)  AS employee_name,
	stpa.mark_type,
	stpa.quantity,
	qros.stage_close_quantity,
	stpa.created_at AS scan_date,
	qros.stage_close_line_id,
	l.name AS stage_close_line,
	qros.stage_close_date,
	w.week AS stage_close_week,
	qros.operations,
	qros.operations_performed,
	
	CASE
		WHEN ((qros.operations_performed * 1.0) / qros.operations) > 1 THEN 1
		ELSE ((qros.operations_performed * 1.0) / qros.operations)
	END AS qr_efficacy
	
FROM (
	SELECT apqo.qr_id,
		apqo.cust_ord,
		apqo.style_id,
		apqo.stage_id,
		apqo.operation_id,
		apqo.operations,
		apqo.operations_performed,
		apqs.stage_close_line_id,
		apqs.stage_close_quantity,
		apqs.stage_close_date
	FROM process.atomic_replacement_qr_operation_performed AS apqo
	INNER JOIN process.atomic_replacement_qr_stage AS apqs 	
	ON apqo.qr_id = apqs.qr_id
	AND apqo.stage_id = apqs.stage_id
	INNER JOIN (
		SELECT sq.id AS qr_id,
			stp.stage_id,
			MAX(stp.created_at_short) as date
		FROM source_atomic_sfc.scan_transact_production AS stp
		INNER JOIN source_atomic_sfc.scan_qr AS sq
		ON stp.sfc_scan_qr_id = sq.id
		WHERE sq.production_prefix = 'R'
		AND stp.fingerprint NOT LIKE 'Carga%'
		AND stp.operation_id NOT IN (
			SELECT op.id
			FROM source_atomic.stage AS s
			INNER JOIN source_atomic_sfc.operation_production AS op
			ON s.id = op.stage_id
			WHERE s.affect_efficacy_operations = 1
			AND op.exception_efficacy = 1)
		GROUP BY sq.id,
			stp.stage_id
	) AS qsd
	ON apqo.qr_id = qsd.qr_id
	AND apqo.stage_id = qsd.stage_id
) AS qros

INNER JOIN source_atomic.stage AS s 
ON qros.stage_id = s.id

INNER JOIN source_atomic_sfc.operation_production AS op
ON qros.operation_id = op.id

LEFT JOIN source_atomic.line AS l
ON qros.stage_close_line_id = l.id

LEFT JOIN source_atomic_sfc.scan_transact_production AS stpa
ON qros.qr_id = stpa.sfc_scan_qr_id
AND qros.operation_id = stpa.operation_id
AND qros.stage_id = stpa.stage_id
AND stpa.fingerprint NOT LIKE 'Carga%'

LEFT JOIN source_etalent.employee AS e
ON stpa.cod_employee = e.cod_employee

LEFT JOIN source_atomic.line as li
ON stpa.line_id = li.id

LEFT JOIN source_accesorios.weeks AS w
ON CONVERT(date, qros.stage_close_date) = w.day