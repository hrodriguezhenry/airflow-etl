SELECT pv.id,
    pv.product_id,
    pv.presentation_id,
    pv.size_id,
    pv.is_big_tall,
    pv.sku,
    CASE 
        WHEN pv.active = 'Y' THEN 1 
        WHEN pv.active = 'N' THEN 0 
        ELSE NULL 
    END AS active,
    pv.created_at,
    pv.updated_at
FROM product_variants AS pv