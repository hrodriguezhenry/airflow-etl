SELECT ib.id,
	ib.rfid_tag_nbr,
	ib.bundle_nbr,
	ib.qty,
	ib.CustOrdHdrNumber AS cust_ord_hdr_number,
	ib.bundle_size,
	ib.bundle_color,
	ib.bundle_orig_qty,
	ib.status
FROM Inspection_Bundle AS ib
WHERE ib.deleted_at IS NULL
AND DATE(ib.created_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)