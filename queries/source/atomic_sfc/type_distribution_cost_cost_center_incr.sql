SELECT ssdccc.id,
	ssdccc.cost_center,
	ssdccc.type_distribution,
	ssdccc.stage_id,
	ssdccc.stage_name_map,
	ssdccc.costco,
	ssdccc.active,
	ssdccc.created_at,
	ssdccc.updated_at
FROM SFC_Type_Distribution_Cost_Cost_Center AS ssdccc
WHERE ssdccc.deleted_at IS NULL