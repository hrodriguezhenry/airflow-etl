SELECT sdo.id,
	sdo.scan_type,
	sdo.cust_ord_hdr_number,
	sdo.classified_boxes,
	sdo.total_boxes,
	sdo.total_boxes_fgi,
	sdo.boxes_processed_qis,
	sdo.completed_received,
	sdo.completed_devolution,
	sdo.devolution_at,
	sdo.devolution_by,
	sdo.comment_close,
	sdo.accounted,
	sdo.old_process,
	sdo.created_at
FROM SFC_Devolution_Order AS sdo
WHERE sdo.deleted_at IS NULL
AND CONVERT(date, sdo.updated_at) >= CONVERT(date, GETDATE() -3)