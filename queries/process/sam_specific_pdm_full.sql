SELECT cfv.final_value AS style_id,
	cfvc.input_field_id AS input_field_with_id,
	sz.sz_dim_det_number,
	cfvc.final_value AS "width",
	sz.measure_a,
	'N' AS delete_row
FROM source_pdm.cf_field_value AS cfv
LEFT JOIN source_pdm.cf_field_value AS cfvc
ON cfv.form_id = cfvc.form_id
AND cfv.circulation_history_id = cfvc.circulation_history_id
AND cfvc.input_field_id IN (29, 33, 40, 41, 1502)
LEFT JOIN source_pdm.cf_field_value AS cfvd
ON cfv.form_id = cfvd.form_id
AND cfv.circulation_history_id = cfvd.circulation_history_id
AND cfvd.input_field_id = 548
LEFT JOIN source_pdm.size_catalog AS sz
ON cfvd.field_value = CONVERT(CHAR, sz.sizes_names_id)
WHERE cfv.input_field_id = 14
GROUP BY cfv.final_value,
	cfvc.input_field_id,
	sz.sz_dim_det_number,
	cfvc.final_value,
	sz.measure_a