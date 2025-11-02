SELECT stpa.sfc_scan_qr_id AS scan_qr_id,
	stpa.stage_id,
	stpa.line_id,
	stpa.operation_id,
	ma.cod_employee,
	stpa.quantity,
	((stpa.standard_time * stpa.quantity) / stpa.quantity_checkin) AS time_with_worked,
	ctw.time_worked,
	stpa.created_at_short AS date,
	stpa.created_at AS scan_date
FROM source_atomic_sfc.scan_transact_production AS stpa
INNER JOIN source_atomic_sfc.group_mark_ref AS gmra
ON stpa.group_mark_id = gmra.group_mark_id
INNER JOIN source_atomic_sfc.mark AS ma
ON gmra.mark_id = ma.id
INNER JOIN (
	SELECT qcd.cod_employee,
		ctd.time_worked / qcd.qr_quantity AS time_worked,
		qcd.date
	FROM (
		SELECT COUNT(stp.sfc_scan_qr_id) AS qr_quantity,
			m.cod_employee,
			m.checkin_short AS date
		FROM source_atomic_sfc.scan_transact_production AS stp
		INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
		ON stp.group_mark_id = gmr.group_mark_id
		INNER JOIN source_atomic_sfc.mark AS m
		ON gmr.mark_id = m.id
		GROUP BY m.cod_employee,
			m.checkin_short
	) AS qcd
	
	INNER JOIN (
		SELECT m.cod_employee,
			(CONVERT(NUMERIC(37, 13), DATEDIFF_BIG(MILLISECOND, MIN(m.checkin), MAX(m.checkout))) / 3600000.0) -
			SUM(CONVERT(NUMERIC(37, 13), ISNULL(DATEDIFF_BIG(MILLISECOND, me."start", me."end"), 0)) / 3600000.0) AS time_worked,
			m.checkin_short AS date
		FROM source_atomic_sfc.mark AS m
		LEFT JOIN source_atomic_sfc.mark_event AS me
		ON m.id = me.mark_id
		AND me.event_type_id = 1
		GROUP BY m.cod_employee,
			m.checkin_short
	) AS ctd
	ON qcd.cod_employee = ctd.cod_employee
	AND qcd.date = ctd.date
) AS ctw
ON ma.checkin_short = ctw.date
AND ma.cod_employee = ctw.cod_employee