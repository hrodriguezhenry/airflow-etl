SELECT cld.id,
	cld.cut_leather_id,
	cld.sz_dim_number,
	cld.large_size,
	cld.input_field_id,
	cld.layer_type,
	cld.width_layer,
	cld.quantity,
	cld."status",
	cld.created_at
FROM Cut_Leather_Detail cld
WHERE cld.deleted_at IS NULL
AND CONVERT(date, cld.updated_at) >= CONVERT(date, GETDATE() -3)