SELECT sls.id,
    sls.uid,
    sls.stage_id,
    sls.sup_cod_employee,
    sls.active,
    sls.created_at
FROM SFC_Layout_Station AS sls
WHERE sls.deleted_at IS NULL