SELECT w.reaL_year AS "year",
	w.real_month AS "month",
	w.week,
	w.day AS date,
	CONCAT('#', ot.number) AS ticket_number,
	CONCAT(os.firstname, ' ', os.lastname) AS agent,
	IIF(os.isactive = 0, 'N', 'Y') AS active_agent,
	otc.subject,
	ota.name AS team,
	ou.name AS "user",
	ot.created AS creation_date,
	ot.closed AS close_date,
	otp.priority,
	oht.topic AS general_theme,
	ohta.topic AS specific_topic,
	osl.name AS sla,
	osl.grace_period AS assigned_hours,
    
	CASE 
		WHEN (
			DATEDIFF(minute, ot.created, ot.closed) / 60.0 - DATEDIFF(DAY, ot.created, ot.closed) * 15 -
			(9 * (
				SELECT COUNT(*)
				FROM source_accesorios.weeks AS w
				WHERE w.laboral_day = 'N'
				AND w.day BETWEEN ot.created AND ot.closed
				)
			)
		) < 0 THEN 0 
	ELSE (
		DATEDIFF(minute, ot.created, ot.closed) / 60.0 - DATEDIFF(DAY, ot.created, ot.closed) * 15 -
		(9 * (
			SELECT COUNT(*)
			FROM source_accesorios.weeks AS w
			WHERE w.laboral_day = 'N'
			AND w.day BETWEEN ot.created AND ot.closed
			)
		)
	)
	END AS working_hours,

	CASE
		WHEN (
			DATEDIFF(minute, ot.created, ot.closed) / 60.0 - DATEDIFF(DAY, ot.created, ot.closed) * 15 -
			(9 * (
				SELECT COUNT(*)
				FROM source_accesorios.weeks AS w
				WHERE w.laboral_day = 'N'
				AND w.day BETWEEN ot.created AND ot.closed
				)
			)
		) <= osl.grace_period THEN 'En Tiempo'
	ELSE 'Tarde' END AS sla_status
    
FROM source_osticket.ost_ticket AS ot
INNER JOIN source_osticket.ost_ticket_cdata AS otc
ON ot.ticket_id = otc.ticket_id
INNER JOIN source_osticket.ost_user AS ou
ON ot.user_id = ou.id
INNER JOIN source_osticket.ost_staff AS os
ON ot.staff_id = os.staff_id
INNER JOIN source_osticket.ost_sla AS osl
ON ot.sla_id = osl.id
INNER JOIN source_osticket.ost_help_topic AS oht
ON ot.topic_id = oht.topic_id
INNER JOIN source_osticket.ost_ticket_priority AS otp
ON oht.priority_id = otp.priority_id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, ot.created) = w.day
LEFT JOIN source_osticket.ost_help_topic AS ohta
ON oht.topic_pid = ohta.topic_id
LEFT JOIN source_osticket.ost_team AS ota
ON ot.team_id = ota.team_id
LEFT JOIN source_osticket.ost_ticket_status AS ots
ON ot.status_id = ots.id
WHERE os.dept_id = 1
AND ots.id = 2
AND w.day >= '2024-01-01';