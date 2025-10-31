SELECT sct.id,
    sct.name,
    sct.active,
    sct.created_at
FROM SFC_Course_Type AS sct
WHERE sct.deleted_at IS NULL
AND CONVERT(date, sct.updated_at) >= CONVERT(date, GETDATE() - 1)