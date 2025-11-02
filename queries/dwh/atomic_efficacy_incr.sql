WITH efficacy_qr AS (
	SELECT DISTINCT aes.cust_ord
	FROM process.atomic_efficacy_scan AS aes
	WHERE aes.date >= CONVERT(date, GETDATE() -9)
)

SELECT aeqc.qr_id,
	aeqc.cust_ord,
	aeqc.style_id,
	aeqc.stage_id,
	aeqc.stage,
	aeoq.operation,
	aeoq.cod_employee,
	aeoq.employee_name,
	aeoq.mark_type,
	aeqc.close_quantity,
	aeoq.scan_date,
	aeqc.close_line,
	aeqc.close_date,
	aeqc.close_week,
	aeqc.close_year,
	aeoq.quantity_operations,
	aeoq.quantity_operations_performed,
	
	CASE
		WHEN ((aeoq.quantity_operations_performed * 1.0) / aeoq.quantity_operations) > 1 THEN 1
		ELSE ((aeoq.quantity_operations_performed * 1.0) / aeoq.quantity_operations)
	END AS qr_efficacy
	
FROM efficacy_qr AS eq
INNER JOIN process.atomic_efficacy_qr_close AS aeqc
ON eq.cust_ord = aeqc.cust_ord
INNER JOIN process.atomic_efficacy_operation_quantity AS aeoq
ON aeqc.qr_id = aeoq.qr_id
AND aeqc.stage_id = aeoq.stage_id