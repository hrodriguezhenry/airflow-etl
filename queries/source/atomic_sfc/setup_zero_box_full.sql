SELECT sszb.id,
	sszb.scan_transact_id,
	sszb.sfc_setup_variable_id,
	sszb.sfc_setup_variable_value_id,
	sszb.technical_sheet_value,
	sszb.user_set_value,
	sszb.manual_set_sheet_value,
	sszb.approved_by,
	sszb.created_at
FROM SFC_Setup_Zero_Box AS sszb
WHERE sszb.deleted_at IS NULL