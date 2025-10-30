SELECT sgm.id,
	sgm.created_at
FROM SFC_Group_Mark AS sgm
WHERE sgm.deleted_at IS NULL