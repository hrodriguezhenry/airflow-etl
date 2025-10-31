SELECT spa.id,
    spa.microzone_id,
    spa.line_id,
    spa.operation_id,
    spa.sfc_scan_qr_id,
    spa.scan_transact_id,
    spa.revision_id,
    spa.rejected_units,
    spa.units_rejected_first_inspection,
    spa.quantity,
    spa.date_scan,
    spa.date_after_stage,
    spa.date_rejected,
    spa.criterion,
    spa.second_criterion,
    spa.created_at
FROM SFC_Production_Advance AS spa
WHERE spa.deleted_at IS NULL
AND CONVERT(date, spa.updated_at) >= CONVERT(date, GETDATE() - 1)