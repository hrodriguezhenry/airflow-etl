SELECT ssy.id,
	ssy.stage_system_id,
	ssy.line_id,
	ssy.bonus_efficiency_area_detail_id,
	ssy."status",
	'N' AS delete_row
FROM Station_System AS ssy
WHERE ssy.deleted_at IS NULL