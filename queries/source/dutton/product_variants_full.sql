SELECT pv.id,
    pv.product_id,
    pv.presentation_id,
    pv.size_id,
    pv.is_big_tall,
    pv.sku,
    pv.active,
    pv.created_at,
    pv.updated_at
FROM product_variants AS pv