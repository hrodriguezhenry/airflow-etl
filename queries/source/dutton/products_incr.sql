SELECT p.id,
    p.code,
    p.color_id,
    p.category_id,
    p.description,
    p.base_price,
    p.width,
    p.web_name,
    p.web_description,
    p.bullet_points,
    p.is_active,
    p.created_at,
    p.updated_at
FROM products AS p
WHERE DATE(p.updated_at) >= CURDATE() - INTERVAL 3 DAY