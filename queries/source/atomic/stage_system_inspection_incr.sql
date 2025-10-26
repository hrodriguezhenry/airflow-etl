SELECT ss.id,
	ss.stage_id,
	'N' AS delete_row
FROM Stage_System AS ss
WHERE ss.menu_id = 13
AND ss.deleted_at IS NULL