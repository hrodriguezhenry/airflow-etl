SELECT f.user_id,
	f.school_id,
	f.created_at,
	f.updated_at
FROM favorite AS f
WHERE f.updated_at >= DATE_ADD(CURDATE(), INTERVAL 2 DAY)