SELECT c.id,
    c.name,
    c.description,
    c.status,
    c.created_at,
    c.updated_at
FROM categories AS c
WHERE DATE(c.updated_at) >= CURDATE() - INTERVAL 3 DAY