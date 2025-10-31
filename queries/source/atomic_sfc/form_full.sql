SELECT sf.id,
    sf."name",
    sf.created_at,
    sf.updated_at
FROM SFC_Form AS sf
WHERE sf.deleted_at IS NULL