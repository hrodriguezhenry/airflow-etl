SELECT sm.id,
    sm.stage_id,
    sm.line_id,
    sm.operation_id,
    sm.cod_employee,
    sm.mark_type,
    sm.fingerprint,
    sm.checkin,
    sm.checkin_short,
    sm.checkout,
    sm.automatic_checkout,
    sm.time_out,
    sm.sfc_reason,
    sm.created_at,
    sm.group_machine,
    sm.machine_fixed_asset,
    sm.machine_id,
    sm.layout_station_id
FROM SFC_Mark AS sm
WHERE sm.deleted_at IS NULL
AND CONVERT(date, sm.updated_at) >= CONVERT(date, GETDATE() - 1)