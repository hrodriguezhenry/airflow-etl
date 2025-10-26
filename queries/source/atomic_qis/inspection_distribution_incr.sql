SELECT id.id,
	id.revision_id,
	id.qty_units,
	id.qty_units_repaired,
	id.created_at
FROM  Inspection_Distribution AS id
WHERE id.deleted_at IS NULL
AND DATE(id.created_at) >= DATE_SUB(CURDATE(), INTERVAL 3 DAY)