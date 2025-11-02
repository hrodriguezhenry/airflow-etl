SELECT pstl.ticket_number,
	pstl.h_transport,
	pstl.loc_code,
	pstl.cust_ord,
	cod.stl_number AS style_id,
	c.clr_desc AS color,
	sdd.sz_dim_det_size AS size,
	pstl.mat_code,
	pstl.quantity,
	u.usr_name AS user_name,
	pstl.traffic_plant,
	pstl.h_transport_creation_date,
	pstl.h_transport_assignment_date,
	pstl.h_transport_date_reception_plant_cut,
	pstl.last_ticket_scan_date,
	pstl.issuing_cut,
	pstl.status,
	pstl.location
FROM process.proaktiv_scans_traffic_locations AS pstl
INNER JOIN source_proaktiv.cust_ord_hdr AS coh
ON REPLACE(pstl.cust_ord, 'S', 'T') = coh.cust_ord_hdr_number
INNER JOIN source_proaktiv.materials AS m
ON pstl.mat_code = m.mat_code
INNER JOIN source_proaktiv.cust_ord_detail AS cod
ON coh.cust_ord_hdr_number = cod.cust_ord_hdr_number
AND m.sz_dim_det_number = cod.sz_dim_det_number
INNER JOIN source_proaktiv.sz_dim_detail AS sdd
ON m.sz_dim_det_number = sdd.sz_dim_det_number
INNER JOIN source_proaktiv.colors AS c
ON cod.clr_number = c.clr_number
LEFT JOIN source_proaktiv.users AS u
ON pstl.user_number = u.usr_number