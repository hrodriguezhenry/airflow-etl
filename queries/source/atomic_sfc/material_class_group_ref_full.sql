SELECT smcgr.id,
	smcgr.material_class_group_id,
	smcgr.mat_cls_number,
	smcgr.created_at,
	smcgr.updated_at
FROM SFC_Material_Class_Group_Ref AS smcgr
WHERE smcgr.deleted_at IS NULL