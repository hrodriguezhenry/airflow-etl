SELECT r.id,
    r.customer_order_number_request,
    r.customer_order_number_response,
    r.id_operation,
    r.customer_number,
    r.customer_order_type,
    r.color_number,
    r.suggeste_units,
    r.requeste_units,
    r."status",
    r.user_autorization,
    r.reposition_of_reposition,
    r.created_at,
    r.on_time,
    r.end_production_date,
    r.exportation_date,
    r.id_last_request,
    r.is_pre_auditoria,
    r."active",
    r.out_time
FROM Reposition AS r
WHERE r.deleted_at IS NULL
AND CONVERT(date, r.updated_at) >= CONVERT(date, GETDATE() -3)