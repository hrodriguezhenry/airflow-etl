WITH hour_number AS (
   SELECT 0 AS hour
   UNION ALL
   SELECT hour + 1
   FROM hour_number
   WHERE hour < 23
)

SELECT mslocc."day",
	mslocc.mark_id,
	mslocc.stage_id,
	mslocc.line_id,
	mslocc.operation_id,
	mslocc.cod_employee,
	ISNULL(mtww.quantity, 0) AS quantity,
	hn.hour,

	CASE
		WHEN DATEPART(HOUR, mslocc.checkin) = hn.hour AND DATEPART(HOUR, mslocc.checkout) = hn.hour
			THEN DATEDIFF(MILLISECOND, CONVERT(TIME, mslocc.checkin), CONVERT(TIME, mslocc.checkout))/3600000.0
		WHEN DATEPART(HOUR, mslocc.checkin) = hn.hour AND DATEPART(HOUR, mslocc.checkout) != hn.hour
			THEN DATEDIFF(MILLISECOND, CONVERT(TIME, mslocc.checkin), DATEADD(HOUR, hn.hour + 1, CONVERT(TIME, '00:00:00')))/3600000.0
		WHEN DATEPART(HOUR, mslocc.checkout) = hn.hour AND DATEPART(HOUR, mslocc.checkin) != hn.hour
			THEN DATEDIFF(MILLISECOND, DATEADD(HOUR, hn.hour, CONVERT(TIME, '00:00:00')), CONVERT(TIME, mslocc.checkout))/3600000.0
		ELSE 1
	END time_worked,
	
	1 AS time_worked_standard,
	ISNULL(mtww.time_with_worked, 0) AS time_with_worked
	
FROM hour_number AS hn

INNER JOIN (
	SELECT m.id as mark_id,
		m.stage_id,
		m.line_id,
		m.operation_id,
		m.cod_employee,
		m.checkin_short AS "day",
		m.checkin,
		m.checkout
	FROM source_atomic_sfc.mark AS m
) AS mslocc
ON hn.hour BETWEEN DATEPART(HOUR, mslocc.checkin)
AND DATEPART(HOUR, mslocc.checkout)

LEFT JOIN (
	SELECT m.id AS mark_id,
		m.stage_id,
		m.line_id,
		m.operation_id,
		m.cod_employee,
		DATEPART(HOUR,stp.created_at) AS hour,
		SUM(stp.quantity) as quantity,
		SUM((stp.standard_time * stp.quantity) / IIF(stp.quantity_checkin = 0, 1, stp.quantity_checkin)) AS time_with_worked
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.group_mark_ref AS gmr
	ON stp.group_mark_id = gmr.group_mark_id
	INNER JOIN source_atomic_sfc.mark AS m
	ON gmr.mark_id = m.id
	GROUP BY m.id,
		m.stage_id,
		m.line_id,
		m.operation_id,
		m.cod_employee,
		DATEPART(HOUR,stp.created_at)
) AS mtww
ON mslocc.mark_id = mtww.mark_id
AND mslocc.stage_id = mtww.stage_id
AND mslocc.line_id = mtww.line_id
AND mslocc.operation_id = mtww.operation_id
AND mslocc.cod_employee = mtww.cod_employee
AND hn.hour = mtww.hour

WHERE mslocc."day" >= CONVERT(date, GETDATE() - 14)