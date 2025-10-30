SELECT smcg.id,
	smcg.name,
	smcg.active,
	smcg.created_at,
	smcg.updated_at,
	smcg.deleted_at
FROM SFC_Material_Class_Group AS smcg
WHERE smcg.deleted_at IS NULL