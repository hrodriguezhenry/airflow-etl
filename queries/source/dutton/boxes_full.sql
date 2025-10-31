SELECT b.id,
    b.product_variant_id,
    b.box_code,
    IF(b.received_at = '0000-00-00 00:00:00', NULL, b.received_at) AS received_at,
    b.sold_at,
    b.status,
    b.reserved_for_order_id,
    b.created_at,
    b.updated_at
FROM boxes AS b