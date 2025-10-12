SELECT m.municipality_id,
	m.department_id,
	m.`name`,
	m.ine_code,
	m.created_at,
	m.updated_at
FROM municipality AS m
WHERE m.updated_at >= DATE_ADD(CURDATE(), INTERVAL 2 DAY)