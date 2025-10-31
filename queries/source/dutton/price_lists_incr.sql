SELECT pl.id,
    pl.name,
    pl.description,
    pl.type_formula,
    pl.formula_margin,
    pl.active,
    pl.created_at,
    pl.updated_at
FROM price_lists AS pl
WHERE DATE(pl.updated_at) >= CURDATE() - INTERVAL 3 DAY