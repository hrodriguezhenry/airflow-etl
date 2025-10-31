SELECT s.id,
    s.product_variant_id,
    s.available_boxes,
    s.reserved_boxes,
    s.sold_boxes,
    s.created_at,
    s.updated_at
FROM stocks AS s