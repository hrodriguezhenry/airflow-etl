SELECT s.stl_number AS style_id,
	sd.sz_dim_det_number,
	sl.input_field_id_pdm AS input_field_with_id,
	b.bom_desc AS layer,
	sd.sz_dim_det_size AS size,
	sd.sz_dim_det_order AS size_order,
	MAX(mav.mat_presentation) AS "format",
	mc.mat_cls_name AS material_class,
	m.mat_cls_number,
	'N' AS delete_row
FROM source_proaktiv.bom AS b
INNER JOIN source_proaktiv.styles AS s
ON b.stl_number = s.stl_number
AND b.clr_number = s.clr_number
INNER JOIN source_atomic_sfc.size_detail AS sd
ON b.sz_dim_det_number = sd.sz_dim_det_number
INNER JOIN source_proaktiv.materials AS m
ON b.mat_code = m.mat_code
INNER JOIN source_proaktiv.mat_cls AS mc
ON m.mat_cls_number = mc.mat_cls_number
INNER JOIN source_proaktiv.materials_alt_vendor AS mav
ON b.mat_code = mav.mat_code
AND mav.default_vendor = 'Y'

INNER JOIN source_atomic.style_layer sl
ON CASE	
		WHEN b.bom_desc = 'LINNING' THEN 'LINING'
		WHEN b.bom_desc = 'FILLER1' THEN 'FILLER'
		ELSE b.bom_desc
	END = REPLACE(sl.layer_description, ' ', '')
	
WHERE b.bom_desc IN ('TOP', 'LINNING', 'LINING', 'FILLER', 'FILLER1', 'FILLER2', 'FILLER3', 'FILLER4')
GROUP BY s.stl_number,
	sd.sz_dim_det_number,
	sl.input_field_id_pdm,
	b.bom_desc,
	sd.sz_dim_det_size,
	sd.sz_dim_det_order,
	mc.mat_cls_name,
	m.mat_cls_number