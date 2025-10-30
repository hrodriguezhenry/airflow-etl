SELECT smes.id,
	smes.mark_event_id,
	smes.mark_event_group_id,
	smes.start,
	smes."end",
	smes.sent_notification,
	smes.status,
	smes.name_mechanical,
	smes.cod_employee_mechanical,
	smes.category_close,
	smes.category_close_id,
	smes.end_comment,
	smes.rating,
	smes.created_at,
	smes.updated_at
FROM SFC_Mark_Event_Support AS smes
WHERE smes.deleted_at IS NULL