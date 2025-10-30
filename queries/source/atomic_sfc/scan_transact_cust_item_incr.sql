SELECT sstci.id,
	sstci.cod_employee,
	sstci.stl_cust_item,
	sstci.old_stl_cust_item,
	sstci.operation_id,
	sstci.old_operation_id,
	sstci.size,
	sstci.old_size,
	sstci.date_scan,
	sstci.dif_in_hours,
	sstci.dif_in_minutes,
	sstci.style_last_day
FROM SFC_Scan_Transact_CustItem AS sstci
WHERE sstci.deleted_at IS NULL
AND CONVERT(date, sstci.date_scan) >= CONVERT(date, GETDATE() -3)