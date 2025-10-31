SELECT pi.id,
    pi.product_id,
    pi.image_path,
    pi.is_default,
    pi.`order`,
    pi.alt_text,
    pi.created_at,
    pi.updated_at
FROM product_images AS pi
WHERE DATE(pi.updated_at) >= CURDATE() - INTERVAL 3 DAY