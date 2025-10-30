SELECT sgm.id,
	sgm.created_at
FROM SFC_Group_Mark AS sgm
WHERE sgm.deleted_at IS NULL
AND CONVERT(date, sgm.updated_at) >= CONVERT(date, GETDATE() -3)