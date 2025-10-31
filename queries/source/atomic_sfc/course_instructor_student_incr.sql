SELECT scis.id,
    scis.course_instructor_id,
    scis.cod_employee,
    scis.score,
    scis.result,
    scis.expected_days,
    scis.completed_days,
    scis.status,
    scis.last_close_at,
    scis.last_close_by,
    scis.expiration_date,
    scis.certificate,
    scis.created_at
FROM SFC_Course_Instructor_Student AS scis
WHERE scis.deleted_at IS NULL
AND CONVERT(date, scis.updated_at) >= CONVERT(date, GETDATE() - 1)