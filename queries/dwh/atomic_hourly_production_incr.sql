SELECT w.year,
	w.week,
	w.day AS date,
	
	CASE
		WHEN st.cod_employee IS NULL AND st.mark_type = 'group' THEN 0
		ELSE st.cod_employee
	END cod_employee,
	
	CASE
		WHEN st.cod_employee IS NULL AND st.mark_type = 'group' THEN 'Grupal'
		ELSE ee.employee_full_name
	END name,

	st.mark_type,
	ee.position,
	st.operation_id,
	o.operation,
	st.line_id,
	l.name AS line,
	st.stage_id,
	s.name AS stage,
	sq.cust_ord_hdr_number,
	srp.style_id AS style,
	st.sfc_scan_qr_id,
	st.quantity,
	st.standard_time AS sam,
	
	CASE 
		WHEN DATEPART(HOUR, st.created_at) < 12 THEN CONCAT(DATEPART (HOUR, st.created_at), ':00 am') 
		ELSE CONCAT(DATEPART(HOUR, st.created_at), ':00 pm') 
	END hour,
	
	st.created_at
	
FROM (
	SELECT CONVERT(VARCHAR, stp.sfc_scan_qr_id) AS sfc_scan_qr_id,
		stp.stage_id,
		stp.line_id,
		stp.operation_id,
		stp.style_route_id,
		stp.mark_type,
		stp.cod_employee,
		stp.standard_time,
		stp.quantity,
		stp.created_at,
		stp.created_at_short
	FROM source_atomic_sfc.scan_transact_production AS stp
	WHERE stp.created_at_short >= CONVERT(date, GETDATE() -2)
	
	UNION ALL
	
	SELECT strm.rmi_ticket,
		strm.stage_id,
		strm.line_id,
		strm.operation_id,
		strm.style_route_id,
		strm.mark_type,
		strm.cod_employee,
		strm.standard_time,
		strm.quantity,
		strm.created_at,
		strm.created_at_short
	FROM source_atomic_sfc.scan_transact_rmi AS strm
	WHERE strm.created_at_short >= CONVERT(date, GETDATE() -2)
) AS st

INNER JOIN source_accesorios.weeks AS w
ON st.created_at_short = w.day

INNER JOIN (
	SELECT op.id,
		op.operation
	FROM source_atomic_sfc.operation_production AS op
	
	UNION ALL 
	
	SELECT ormi.id,
		ormi.operation
	FROM source_atomic_sfc.operation_rmi AS ormi
	WHERE ormi.id IN( 1384, 1383)
) AS o
ON st.operation_id = o.id

INNER JOIN source_atomic.line AS l
ON st.line_id = l.id
INNER JOIN source_atomic.stage AS s
ON st.stage_id = s.id
LEFT JOIN source_atomic_sfc.scan_qr AS sq
ON st.sfc_scan_qr_id = CONVERT(VARCHAR, sq.id)
LEFT JOIN source_atomic_sfc.style_route_production AS srp
ON st.style_route_id = srp.id
LEFT JOIN dwh.etalent_employees AS ee
ON st.cod_employee = ee.cod_employee
ORDER BY w.day ASC