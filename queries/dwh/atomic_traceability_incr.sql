SELECT atc.cust_ord,
	atc.style_id,
	atc.qr_id,
	atc.quantity,
	atc.size,
	atc.employee_name,
	atc.operation,
	atc.date,
	atc.stage,
	atc.column_name,
	atd.value
FROM process.atomic_traceability_columns AS atc
LEFT JOIN process.atomic_traceability_detail AS atd
ON atc.qr_id = atd.qr_id
AND atc.column_name = atd.column_name