SELECT atc.cust_ord,
	atc.style_id,
	atc.qr_id,
	atc.quantity,
	atc.employee_name,
	atc.operation,
	atc.date,
	atc.stage,
	atc.column_name,
	atd.value,
	'N' AS delete_row
FROM process.atomic_traceability_columns_zero_box AS atc
LEFT JOIN process.atomic_traceability_detail_zero_box AS atd
ON atc.qr_id = atd.qr_id
AND atc.column_name = atd.column_name