SELECT ssctc.id,
	ssctc.closure_type,
	ssctc.active,
	ssctc.created_at,
	ssctc.created_by,
	ssctc.udpated_at,
	ssctc.updated_by,
	ssctc.deleted_at,
	ssctc.deleted_by
FROM SFC_Support_Closure_Type_Category AS ssctc
WHERE ssctc.deleted_at IS NULL