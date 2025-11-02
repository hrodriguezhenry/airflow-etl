SELECT ra.rmi_ticket_number AS ticket_number,
	hthd.h_transport,
	ra.loc_code,
	ra.rmi_reception_cut AS cust_ord,
	ra.mat_code,
	ra.rmi_qty AS quantity,
	ra.usr_number AS user_number,
	l.loc_traffic_plant AS traffic_plant,
	hthd.h_transport_creation_date,
	hthd.h_transport_assignment_date,
	hthd.h_transport_date_reception_plant_cut,
	ra.rmi_last_ticket_scan_date AS last_ticket_scan_date,
	ra.rmi_issuing_cut AS issuing_cut,
	
	CASE
		WHEN ra.rmi_status IS NOT NULL AND ra.rmi_status = 'U' THEN 'Despachado'
		ELSE 'Disponible'
	END AS status,
	
	CASE
		WHEN ra.rmi_issuing_cut IS NOT NULL AND ra.rmi_status = 'U' THEN 'Cuerpos'
		ELSE ra.loc_code
	END AS location
	
FROM source_proaktiv.rmi AS ra
INNER JOIN source_proaktiv.locations AS l
ON ra.loc_code = l.loc_code
LEFT JOIN (
	SELECT hth.h_transport,
		htd.rmi_ticket_number AS ticket_number,
		hth.creation_date AS h_transport_creation_date,
		hth.assignment_date AS h_transport_assignment_date,
		htd.date_reception_plant_cut AS h_transport_date_reception_plant_cut
	FROM source_proaktiv.h_transport_hdr AS hth
	INNER JOIN source_proaktiv.h_transport_detail AS htd
	ON hth.h_transport = htd.h_transport_hdr
	WHERE hth.status = 'CC'
) AS hthd
ON ra.rmi_ticket_number = hthd.ticket_number
WHERE hthd.h_transport IS NOT NULL
AND hthd.h_transport_date_reception_plant_cut IS NOT NULL
OR l.loc_traffic_plant IN ('Planta Cinturones', 'Planta Fajas')

UNION ALL

SELECT rra.rmi_repos_ticket_number AS ticket_number,
	hthd.h_transport,
	rra.loc_code,
	rra.rmi_repos_reception_cut AS cust_ord,
	rra.mat_code,
	rra.rmi_repos_qty AS quantity,
	rra.usr_number AS user_number,
	l.loc_traffic_plant AS traffic_plant,
	hthd.h_transport_creation_date,
	hthd.h_transport_assignment_date,
	hthd.h_transport_date_reception_plant_cut,
	rra.rmi_last_ticket_scan_date AS last_ticket_scan_date,
	rra.rmi_repos_issuing_cut AS issuing_cut,
	
	CASE
		WHEN rra.rmi_repos_issuing_cut is not null and rra.rmi_repos_status = 'U' then 'Despachado'
		ELSE 'Disponible'
	END AS status,
	
	CASE
		WHEN rra.rmi_repos_issuing_cut IS NOT NULL AND rra.rmi_repos_status = 'U' THEN 'Cuerpos'
		ELSE rra.loc_code
	END AS location
	
FROM source_proaktiv.rmi_repos AS rra
INNER JOIN source_proaktiv.locations AS l
ON rra.loc_code = l.loc_code
LEFT JOIN (
	SELECT hth.h_transport,
		htd.rmi_ticket_number AS ticket_number,
		hth.creation_date AS h_transport_creation_date,
		hth.assignment_date AS h_transport_assignment_date,
		htd.date_reception_plant_cut AS h_transport_date_reception_plant_cut
	FROM source_proaktiv.h_transport_hdr AS hth
	INNER JOIN source_proaktiv.h_transport_detail AS htd
	ON hth.h_transport = htd.h_transport_hdr
	WHERE hth.status = 'CC'
) AS hthd
ON rra.rmi_repos_ticket_number = hthd.ticket_number
WHERE hthd.h_transport IS NOT NULL
AND hthd.h_transport_date_reception_plant_cut IS NOT NULL
OR l.loc_traffic_plant IN ('Planta Cinturones', 'Planta Fajas')