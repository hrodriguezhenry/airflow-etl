SELECT ist.id,
	ist.name,
	ist.active
FROM Inspection_Stage AS ist
WHERE ist.deleted_at IS NULL