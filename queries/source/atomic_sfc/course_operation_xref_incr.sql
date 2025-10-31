SELECT scox.id,
    scox.course_id,
    scox.operation_id,
    scox.created_at
FROM SFC_Course_Operation_Xref AS scox
WHERE scox.deleted_at IS NULL
AND CONVERT(date, scox.updated_at) >= CONVERT(date, GETDATE() - 1)