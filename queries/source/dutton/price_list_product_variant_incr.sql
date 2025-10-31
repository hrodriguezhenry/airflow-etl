SELECT plpv.id,
    plpv.price_list_id,
    plpv.product_variant_id,
    plpv.fixed_price,
    plpv.created_at,
    plpv.updated_at
FROM price_list_product_variant AS plpv
WHERE DATE(plpv.updated_at) >= CURDATE() - INTERVAL 3 DAY