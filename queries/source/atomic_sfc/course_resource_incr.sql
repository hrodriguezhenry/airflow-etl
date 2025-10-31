SELECT scr.id,
    scr.course_id,
    scr.file_order,
    scr.name,
    scr.description,
    scr.mime_type,
    scr.upload,
    scr.bucket,
    scr.file_key,
    scr.url,
    scr.temporal_url,
    scr.date_expiration,
    scr.created_at
FROM SFC_Course_Resource AS scr
WHERE scr.deleted_at IS NULL
AND CONVERT(date, scr.updated_at) >= CONVERT(date, GETDATE() - 1)