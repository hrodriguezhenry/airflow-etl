SELECT ssv.id,
	ssv."name",
	ssv.uom,
	ssv.abbreviation,
	ssv.type_value,
	ssv.input_field_pdm,
	ssv.allowed_cost_centers,
	ssv.required_authorization,
	ssv.created_at
FROM SFC_Setup_Variable AS ssv
WHERE ssv.deleted_at IS NULL