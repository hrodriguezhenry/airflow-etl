SELECT smet.id,
	smet.name,
	smet.description,
	smet.mark_type,
	smet.off_standard,
	smet.icon,
	smet.affect_overal,
	smet.max_daily_offstandard,
	smet.max_offstandard_event,
	smet.requires_auth_offstandard,
	smet.active,
	smet.created_at,
	smet.affect_overall
FROM SFC_Mark_Event_Type AS smet
WHERE smet.deleted_at IS NULL