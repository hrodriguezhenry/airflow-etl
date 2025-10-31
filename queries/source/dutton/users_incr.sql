SELECT u.id,
    u.name,
    u.user,
    u.email,
    u.role,
    u.active,
    u.sales_target,
    u.created_at,
    u.updated_at
FROM users AS u
WHERE DATE(u.updated_at) >= CURDATE() - INTERVAL 3 DAY