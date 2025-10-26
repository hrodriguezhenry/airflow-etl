SELECT irr.id,
	irr.revision_id,
	irr.emp_cod,
	irr.station_id,
	irr.`status`,
	irr.last_close_at,
	irr.last_close_by,
	irr.created_at,
	irr.updated_at
FROM Inspection_Revision_Repair AS irr
WHERE irr.deleted_at IS NULL