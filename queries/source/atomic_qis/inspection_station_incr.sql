SELECT ist.id,
	ist.name,
	ist.line,
	ist.atomic_line_id,
	ist.stage_id,
	ist.atomic_stage_id
FROM Inspection_Station AS ist
WHERE ist.deleted_at IS NULL 