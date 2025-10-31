SELECT sc.id,
    sc.course_type_id,
    sc.code,
    sc.name,
    sc.description,
    sc.expected_days,
    sc.expiration_months,
    sc.bench,
    sc.active,
    sc.created_at
FROM SFC_Course AS sc
WHERE sc.deleted_at IS NULL