SELECT sl.id,
	sl.name,
	sl.uuid,
	sl.active,
	sl.created_at
FROM SFC_Location AS sl
WHERE sl.deleted_at IS NULL