SELECT sssox.id,
	sssox.sam_specific_id,
	sssox.operation_id,
	sssox.priority,
	sssox.active
FROM SFC_SAM_Specific_Operation_Xref AS sssox
WHERE sssox.deleted_at IS NULL
AND sssox.active = 1