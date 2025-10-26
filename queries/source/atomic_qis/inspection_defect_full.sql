SELECT id.id,
	id.name,
	id.inspection_group_defect,
	id.operation_id,
	id.defect_group_id,
	id.stage_id,
	id.atomic_stage_id,
	id.active,
	id.reprocess
FROM Inspection_Defect AS id
WHERE id.deleted_at IS NULL