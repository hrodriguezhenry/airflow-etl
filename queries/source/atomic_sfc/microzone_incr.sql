SELECT sm.id,
	sm.name,
	sm.type,
	sm.valid_stages,
	sm.stage_id,
	sm.equivalent_stage_id,
	sm.after_stages,
	sm.stage_qis,
	sm.algorithm,
	sm.last_run_at,
	sm.active,
	sm.created_at
FROM SFC_MicroZone AS sm
WHERE sm.deleted_at IS NULL