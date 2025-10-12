SELECT d.department_id,
	d.`name`,
	d.created_at,
	d.updated_at
FROM department AS d
WHERE d.updated_at >= DATE_ADD(CURDATE(), INTERVAL 2 DAY)