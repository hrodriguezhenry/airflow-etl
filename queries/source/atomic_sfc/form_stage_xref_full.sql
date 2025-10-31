SELECT sfsx.id,
    sfsx.stage_id,
    sfsx.sfc_form_id,
    sfsx.created_at,
    sfsx.updated_at
FROM SFC_Form_Stage_Xref AS sfsx
WHERE sfsx.deleted_at IS NULL