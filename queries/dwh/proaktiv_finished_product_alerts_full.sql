SELECT ISNULL(mcar.material_code, prqm.material_code) AS material_code,
	mcar.consumed_quantity,
	mcar.available_quantity,
	mcar.requested_quantity_8_weeks,
	mcar.requested_quantity_16_weeks,
	mcar.requested_quantity_24_weeks,
	prqm.required_quantity_8_weeks,
	prqm.required_quantity_16_weeks,
	prqm.required_quantity_24_weeks,
	'N' AS delete_row

FROM (
	SELECT ISNULL(pcma.material_code, prqm.material_code) AS material_code,
		pcma.consumed_quantity,
		pcma.available_quantity,
		prqm.requested_quantity_8_weeks,
		prqm.requested_quantity_16_weeks,
		prqm.requested_quantity_24_weeks
	FROM process.proaktiv_consumed_material_available_fp AS pcma
	FULL OUTER JOIN process.proaktiv_requested_quantity_material_fp AS prqm
	ON pcma.material_code = prqm.material_code
) AS mcar

FULL OUTER JOIN process.proaktiv_required_quantity_material_fp AS prqm
ON mcar.material_code = prqm.material_code