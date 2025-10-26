SELECT sl.id,
	sl.layer_description,
	sl.layer_full_description,
	sl.input_field_id_pdm,
	'N' AS delete_row
FROM Style_Layer AS sl