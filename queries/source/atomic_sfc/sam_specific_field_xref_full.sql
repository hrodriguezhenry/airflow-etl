SELECT sssfx.id,
	sssfx.sam_specific_id,
	sssfx.field_id,
	sssfx.value,
	sssfx.max_value,
	sssfx.active
FROM SFC_SAM_Specific_Field_Xref AS sssfx
WHERE sssfx.deleted_at IS NULL
AND sssfx.active = 1