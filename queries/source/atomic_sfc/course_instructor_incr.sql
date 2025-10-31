SELECT sci.id,
    sci.course_id,
    sci.course_type_id,
    sci.cod_employee,
    sci.start_date,
    sci.end_date,
    sci.status,
    sci.last_close_at,
    sci.last_close_by,
    sci.created_at
FROM SFC_Course_Instructor AS sci
WHERE sci.deleted_at IS NULL
AND CONVERT(date, sci.updated_at) >= CONVERT(date, GETDATE() - 1)