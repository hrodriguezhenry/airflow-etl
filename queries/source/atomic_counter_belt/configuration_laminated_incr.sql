SELECT cbcl.id,
	cbcl.str_field_value,
	cbcl.color_number,
	cbcl.width_mm,
	cbcl.str_final_value,
	cbcl.surplus_alternative_mat_code,
	cbcl.created_at,
	cbcl.updated_at
FROM Counter_Belt_Configuration_Laminated AS cbcl
WHERE cbcl.deleted_at IS NULL
AND cbcl.updated_at >= CONVERT(date, GETDATE() -3)