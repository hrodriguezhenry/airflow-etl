SELECT ist.id,
	ist.stage_id,
	ist.sah,
	ist.units,
	ist.active,
	ist.created_at
FROM Inspection_Standard AS ist
WHERE ist.deleted_at IS NULL