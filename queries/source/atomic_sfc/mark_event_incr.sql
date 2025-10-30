SELECT sme.id,
	sme.mark_id,
	sme.event_type_id,
	sme.start,
	sme."end",
	sme.affect_overall,
	sme.max_daily_offstandard,
	sme.max_offstandard_event,
	sme.offstandard_authorized,
	sme.requires_auth_offstandard,
	sme.revised_at,
	sme.revised_by,
	sme.revised_from,
	sme.created_at
FROM SFC_Mark_Event AS sme
WHERE sme.deleted_at IS NULL
AND CONVERT(date, sme.updated_at) >= CONVERT(date, GETDATE() -3)