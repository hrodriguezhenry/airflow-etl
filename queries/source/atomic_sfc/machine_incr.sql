SELECT sm.id,
	sm.name,
	sm.stage_id,
	sm.active,
	sm.created_at
FROM SFC_Machine AS sm
WHERE sm.deleted_at IS NULL