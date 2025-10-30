SELECT sd.id,
	sd.scan_type,
	sd.cust_ord_hdr_number,
	sd.sfc_scan_qr_id,
	sd.scan_transact_id,
	sd.quantity_rejected_expected,
	sd.quantity_rejected,
	sd.created_at,
	sd.updated_at
FROM SFC_Devolution AS sd
WHERE sd.deleted_at IS NULL