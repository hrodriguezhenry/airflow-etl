SELECT soe.id,
	soe.operation_id,
	soe.stage_close_id
FROM SFC_Operation_Exit AS soe
WHERE soe.deleted_at IS NULL 