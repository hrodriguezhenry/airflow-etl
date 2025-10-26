SELECT l.id,
	l.name,
	l.number,
	l.line_fr,
	l.sfc_plant_id,
	'N' AS delete_row
FROM Line AS l
WHERE l.deleted_at IS NULL