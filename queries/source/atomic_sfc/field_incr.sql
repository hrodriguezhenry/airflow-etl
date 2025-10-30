SELECT sf.id,
	sf.name,
	sf.active
FROM SFC_Field AS sf
WHERE sf.deleted_at IS NULL
AND sf.active = 1