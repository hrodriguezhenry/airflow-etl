SELECT sfa.id,
    sfa.answer,
    sfa.created_at,
    sfa.updated_at
FROM SFC_Form_Answer AS sfa
WHERE sfa.deleted_at IS NULL
AND CONVERT(date, sfa.updated_at) >= CONVERT(date, GETDATE() -3)