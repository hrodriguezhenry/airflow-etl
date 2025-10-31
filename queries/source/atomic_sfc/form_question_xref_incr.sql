SELECT sfqx.id,
    sfqx.sfc_form_id,
    sfqx.sfc_form_question_id,
    sfqx.created_at,
    sfqx.updated_at
FROM SFC_Form_Question_Xref AS sfqx
WHERE sfqx.deleted_at IS NULL
AND CONVERT(date, sfqx.updated_at) >= CONVERT(date, GETDATE() -3)