SELECT u.user_id,
	u.full_name,
	u.email,
	u.password,
	u.`role`,
	u.municipality_id,
	u.created_at,
	u.updated_at
FROM `user` AS u
WHERE u.updated_at >= DATE_ADD(CURDATE(), INTERVAL 2 DAY)