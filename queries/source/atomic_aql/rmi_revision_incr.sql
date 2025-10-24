SELECT arr.id,
	arr.POHdrNumber AS po_hdr_number,
	arr.`no`,
	arr.details,
	arr.boxes,
	arr.units,
	arr.aql_level,
	arr.revision_level,
	arr.max_failures,
	arr.result,
	arr.`status`,
	arr.last_close_at,
	arr.last_close_by,
	arr.created_at
FROM AQL_RMI_Revision AS arr
WHERE arr.deleted_at IS NULL
AND DATE(arr.updated_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)