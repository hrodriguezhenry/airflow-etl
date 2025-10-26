SELECT cbc.id,
	cbc.material_code,
	cbc.material_description,
	cbc.material_class_number,
	cbc.material_class_description,
	cbc.surplus_alternative_mat_code,
	cbc.color_number,
	cbc.width_mm,
	cbc.created_at,
	cbc.updated_at
FROM Counter_Belt_Configuration AS cbc
WHERE cbc.deleted_at IS NULL