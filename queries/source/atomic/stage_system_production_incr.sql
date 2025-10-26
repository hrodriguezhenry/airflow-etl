SELECT ss.id,
	ss.stage_id,
	ss."order",
	ss.efficacy_order,
	ss.next_order,
	ss.efficacy_next_order,
	ss.co_next_order,
	'N' AS delete_row
FROM Stage_System AS ss
WHERE ss.menu_id = 52
AND ss.deleted_at IS NULL