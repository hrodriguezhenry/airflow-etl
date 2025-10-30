SELECT ssrel.id,
	ssrel.code,
	ssrel.message,
	ssrel.sfc_scan_qr_id,
	ssrel.rmi_ticket_number,
	ssrel.operation_id,
	ssrel.group_mark_id,
	ssrel.created_at,
	ssrel.created_from,
	ssrel.updated_at
FROM SFC_Style_Route_Error_Log AS ssrel
WHERE ssrel.deleted_at IS NULL