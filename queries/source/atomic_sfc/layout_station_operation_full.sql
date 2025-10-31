SELECT slso.id,
    slso.layout_id,
    slso.operation_id,
    slso.start_date,
    slso.end_date,
    slso.active,
    slso.created_at
FROM SFC_Layout_Station_Operation AS slso
WHERE slso.deleted_at IS NULL