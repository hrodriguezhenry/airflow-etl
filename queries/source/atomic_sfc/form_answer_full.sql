SELECT sfa.id,
    sfa.answer,
    sfa.created_at,
    sfa.updated_at
FROM SFC_Form_Answer AS sfa
WHERE sfa.deleted_at IS NULL