SELECT c.id,
    c.name,
    c.hex_code,
    c.external_code,
    c.status,
    c.created_at,
    c.updated_at
FROM colors AS c
WHERE DATE(c.updated_at) >= CURDATE() - INTERVAL 3 DAY