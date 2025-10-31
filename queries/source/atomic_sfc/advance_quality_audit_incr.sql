SELECT saqa.id,
    saqa.cod_employee,
    saqa.name_employee,
    saqa.notification_time,
    saqa.start_service,
    saqa.end_service,
    saqa.message,
    saqa.sfc_scan_transact_id,
    saqa.cust_order_number,
    saqa.advance,
    saqa.last_close_by,
    saqa.created_at,
    saqa.updated_at
FROM SFC_Advance_Quality_Audit AS saqa
WHERE saqa.deleted_at IS NULL
AND CONVERT(date, saqa.updated_at) >= CONVERT(date, GETDATE() -3)