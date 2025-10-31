SELECT sct.id,
    sct.name,
    sct.active,
    sct.created_at
FROM SFC_Course_Type AS sct
WHERE sct.deleted_at IS NULL