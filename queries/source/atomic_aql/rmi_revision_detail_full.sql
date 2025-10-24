SELECT arrd.id,
	arrd.revision_id,
	arrd.POHdrNumber AS po_hdr_number,
	arrd.MatCode AS mat_code,
	arrd.boxes,
	arrd.units,
	arrd.audit_boxes,
	arrd.audit_units,
	arrd.rejected_units,
	arrd.`status`,
	arrd.last_close_at,
	arrd.last_close_by,
	arrd.created_at
FROM AQL_RMI_Revision_Detail AS arrd
WHERE arrd.deleted_at IS NULL