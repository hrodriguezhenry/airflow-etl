SELECT sc.id,
	sc.fingerprint,
	sc.stage_id,
	sc.line_id,
	sc.mark_type,
	sc.operation_id,
	sc.layout_station_id,
	sc.fixed_asset,
	sc.machine_fixed_asset,
	sc.group_machine,
	sc.role_id,
	sc.created_at,
	sc.active,
	sc.temp_group,
	sc.printer,
	sc.machine_id
FROM SFC_Configuration AS sc
WHERE sc.deleted_at IS NULL