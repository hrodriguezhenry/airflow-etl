SELECT ir.id,
	ir.bundle_id,
	ir.sfc_scan_qr_id,
	ir.station_id,
	ir.emp_cod,
	ir.no,
	ir.bundle_qty,
	ir.bundle_orig_qty,
	ir.reduce_bundle,
	ir.result,
	ir.status,
	ir.`load`,
	ir.last_close_at,
	ir.created_at,
	ir.created_by
FROM Inspection_Revision AS ir
WHERE ir.deleted_at IS NULL