SELECT cqd.id,
    cqd.customer_quote_id,
    cqd.product_variant_id,
    cqd.quantity,
    cqd.original_price,
    cqd.quote_price,
    cqd.created_by,
    cqd.updated_by,
    cqd.deleted_by,
    cqd.created_at,
    cqd.updated_at,
    cqd.deleted_at
FROM customer_quote_details AS cqd