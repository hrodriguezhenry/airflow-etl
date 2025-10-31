SELECT ps.id,
    ps.scan_type,
    ps.sfc_scan_qr_id,
    ps.stage_id,
    ps.line_id,
    ps.production_route_id,
    ps.quantity,
    ps.created_at
FROM Production_Scan AS ps
WHERE ps.deleted_at IS NULL
AND CONVERT(date, ps.updated_at) >= CONVERT(date, GETDATE() - 2)