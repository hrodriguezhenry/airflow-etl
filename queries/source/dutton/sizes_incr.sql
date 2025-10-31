SELECT s.id,
    s.name,
    s.description,
    s.status,
    s.created_at,
    s.updated_at
FROM sizes AS s
WHERE DATE(s.updated_at) >= CURDATE() - INTERVAL 3 DAY