SELECT sl.level_id,
	sl.`name`,
	sl.created_at,
	sl.updated_at
FROM school_level AS sl
WHERE sl.updated_at >= DATE_ADD(CURDATE(), INTERVAL 2 DAY)