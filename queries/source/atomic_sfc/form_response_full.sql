SELECT sfr.id,
    sfr.sfc_advance_quality_audit_id,
    sfr.cod_employee,
    sfr.completed,
    sfr.created_at,
    sfr.updated_at
FROM SFC_Form_Response AS sfr
WHERE sfr.deleted_at IS NULL