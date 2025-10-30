SELECT sr.id,
	sr.reason,
	sr.type,
	sr.active,
	sr.created_at
FROM SFC_Reason AS sr
WHERE sr.deleted_at IS NULL