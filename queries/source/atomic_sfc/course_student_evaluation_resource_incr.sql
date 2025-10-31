SELECT scser.id,
    scser.course_student_evaluation_id,
    scser.name,
    scser.description,
    scser.bucket,
    scser.file_key,
    scser.file_order,
    scser.url,
    scser.temporal_url,
    scser.date_expiration,
    scser.created_at
FROM SFC_Course_Student_Evaluation_Resource AS scser
WHERE scser.deleted_at IS NULL
AND CONVERT(date, scser.updated_at) >= CONVERT(date, GETDATE() - 1)