SELECT sst.id,
    sst.rmi_ticket,
    sst.stage_id,
    sst.line_id,
    sst.operation_id,
    sst.group_mark_id,
    sst.substitute_group,
    sst.style_route_id,
    sst.mark_type,
    sst.fingerprint,
    sst.cod_employee,
    sst.pay_per_piece,
    sst.standard_time,
    sst.quantity_checkin,
    sst.quantity,
    sst.time,
    sst.status,
    sst.last_close_at,
    sst.manual,
    sst.created_at,
    sst.created_at_short
FROM SFC_Scan_Transact AS sst
WHERE sst.deleted_at IS NULL
AND sst.rmi_ticket IS NOT NULL