SELECT sd.id,
    sd.statistics_id,
    sd.operation_id,
    sd.stage_id,
    sd.line_id,
    sd.group_mark_id,
    sd.station_id,
    sd.cod_employee,
    sd.created_at
FROM Statistics_Detail AS sd
WHERE sd.deleted_at IS NULL
AND CONVERT(date, sd.updated_at) >= CONVERT(date, GETDATE() -3)