SELECT ssvv.id,
	ssvv.sfc_setup_variable_id,
	ssvv."value",
	ssvv.created_at
FROM SFC_Setup_Variable_Value AS ssvv
WHERE ssvv.deleted_at IS NULL
AND CONVERT(date, ssvv.updated_at) >= CONVERT(date, GETDATE() -3)