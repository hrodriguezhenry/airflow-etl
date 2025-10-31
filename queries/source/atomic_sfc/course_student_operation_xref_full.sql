SELECT scsox.id,
    scsox.course_instructor_student_id,
    scsox.operation_id,
    scsox.certificate,
    scsox.expiration_date,
    scsox.created_at
FROM SFC_Course_Student_Operation_Xref AS scsox
WHERE scsox.deleted_at IS NULL