SELECT so.id,
	so.operation,
	so.description,
	so.stage_id,
	so.include_efficacy,
	so.setup_time,
	so.traceability,
	so.active,
	so.sam_specific,
	so.max_rejection,
	so.max_defect,
	so.daily_bonus
FROM SFC_Operation AS so
WHERE so.deleted_at IS NULL
AND so.scan_type = 'rmi_ticket'