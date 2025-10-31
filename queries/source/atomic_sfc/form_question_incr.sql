SELECT sfq.id,
    sfq.question,
    sfq.created_at,
    sfq.updated_at
FROM SFC_Form_Question AS sfq
WHERE sfq.deleted_at IS NULL
AND CONVERT(date, sfq.updated_at) >= CONVERT(date, GETDATE() -3)