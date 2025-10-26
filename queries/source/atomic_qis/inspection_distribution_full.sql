SELECT id.id,
	id.revision_id,
	id.qty_units,
	id.qty_units_repaired,
	id.created_at
FROM  Inspection_Distribution AS id
WHERE id.deleted_at IS NULL