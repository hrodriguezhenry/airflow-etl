SELECT sfrd.id,
    sfrd.sfc_form_response_id,
    sfrd.sfc_form_id,
    sfrd.sfc_form_question_id,
    sfrd.sfc_form_answer_id,
    sfrd.answered,
    sfrd.created_at,
    sfrd.updated_at
FROM SFC_Form_Response_Detail AS sfrd
WHERE sfrd.deleted_at IS NULL