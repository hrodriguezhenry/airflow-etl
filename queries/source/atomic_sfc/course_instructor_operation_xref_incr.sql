SELECT sciox.id,
    sciox.course_instructor_id,
    sciox.operation_id,
    sciox.created_at,
    sciox.updated_at
FROM SFC_Course_Instructor_Operation_Xref AS sciox
WHERE sciox.deleted_at IS NULL
AND CONVERT(date, sciox.updated_at) >= CONVERT(date, GETDATE() - 1)