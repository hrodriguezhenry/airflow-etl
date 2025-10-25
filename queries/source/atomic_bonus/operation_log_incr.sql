SELECT bol.id,
	bol.operation_id,
	bol.max_rejection,
	bol.max_defect,
	bol.active,
	bol.created_at
FROM Bonus_Operation_Log AS bol
WHERE bol.deleted_at IS NULL
AND bol.updated_at >= CONVERT(date, GETDATE() -3)