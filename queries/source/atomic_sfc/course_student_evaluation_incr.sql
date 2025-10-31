SELECT scse.id,
    scse.course_instructor_student_id,
    scse.name,
    scse.score,
    scse.result,
    scse.created_at
FROM SFC_Course_Student_Evaluation AS scse
WHERE scse.deleted_at IS NULL
AND CONVERT(date, scse.updated_at) >= CONVERT(date, GETDATE() - 1)