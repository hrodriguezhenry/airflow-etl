SELECT sfqax.id,
    sfqax.sfc_form_id,
    sfqax.sfc_form_question_id,
    sfqax.sfc_form_answer_id,
    sfqax.created_at,
    sfqax.updated_at
FROM SFC_Form_Question_Answer_Xref AS sfqax
WHERE sfqax.deleted_at IS NULL
AND CONVERT(date, sfqax.updated_at) >= CONVERT(date, GETDATE() -3)