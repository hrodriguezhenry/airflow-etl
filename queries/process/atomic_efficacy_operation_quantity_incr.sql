WITH efficacy_qr AS (
	SELECT DISTINCT aes.cust_ord
	FROM process.atomic_efficacy_scan AS aes
	WHERE aes.date >= CONVERT(date, GETDATE() -9)
)

SELECT aeo.cust_ord,
	aeo.qr_id,
	aeo.stage_id,
	aeo.operation_id,
	op.operation,
	aesca.cod_employee,
	aesca.employee_name,
	aesca.mark_type,
	aesca.scan_date,
	aeo.operation_id_performed,
	qsq.quantity_operations,
	ISNULL(qsqp.quantity_operations_performed, 0) AS quantity_operations_performed
FROM efficacy_qr AS eq
INNER JOIN process.atomic_efficacy_operation_clean AS aeo
ON eq.cust_ord = aeo.cust_ord
INNER JOIN source_atomic_sfc.operation_production AS op
ON aeo.operation_id = op.id

INNER JOIN (
	SELECT aeoa.qr_id,
		aeoa.stage_id,
		COUNT(*) AS quantity_operations
	FROM process.atomic_efficacy_operation_clean AS aeoa
	GROUP BY aeoa.qr_id,
		aeoa.stage_id
) AS qsq
ON aeo.qr_id = qsq.qr_id
AND aeo.stage_id = qsq.stage_id

LEFT JOIN (
	SELECT aeob.qr_id,
		aeob.stage_id,
		COUNT(*) AS quantity_operations_performed
	FROM process.atomic_efficacy_operation_clean AS aeob
	WHERE aeob.operation_id_performed IS NOT NULL
	GROUP BY aeob.qr_id,
		aeob.stage_id
) AS qsqp
ON aeo.qr_id = qsqp.qr_id
AND aeo.stage_id = qsqp.stage_id

LEFT JOIN (
	SELECT aesc.qr_id,
		aesc.stage_id,
		aesc.operation_id,
		MAX(aesc.scan_transact_id) AS scan_transact_id
	FROM process.atomic_efficacy_scan_close AS aesc
	WHERE aesc.first_day_of_week <= aesc.close_first_day_of_week
	GROUP BY aesc.qr_id,
		aesc.stage_id,
		aesc.operation_id
) AS qss
ON aeo.qr_id = qss.qr_id
AND aeo.stage_id = qss.stage_id
AND aeo.operation_id = qss.operation_id

LEFT JOIN process.atomic_efficacy_scan_close AS aesca
ON qss.scan_transact_id = aesca.scan_transact_id