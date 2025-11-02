SELECT CONCAT(stp.cod_employee,' - ', ee.employee_name) AS employee_name,
	sq.cust_ord_hdr_number AS cust_ord,
	s.name AS stage,
	
	CASE
		WHEN stp.operation_id = 1892 AND clp.line IS NOT NULL THEN clp.line
		WHEN stp.operation_id = 1892 AND clp.line IS NULL THEN 'Fuera del Plan'
		WHEN stp.operation_id = 2123 AND clp.line IS NOT NULL THEN clp.line
		WHEN stp.operation_id = 2123 AND clp.line IS NULL THEN 'Fuera del Plan'
		ELSE l.name
	END AS line,
	
	op.operation,
	c.machine_fixed_asset,
	c.group_machine,
	SUM(stp.quantity) AS quantity,
	stp.created_at,
	stp.created_at_short,
	'N' AS delete_row
FROM source_atomic_sfc.scan_transact_production AS stp
INNER JOIN source_atomic_sfc.scan_qr AS sq
ON stp.sfc_scan_qr_id = sq.id
INNER JOIN source_atomic.stage AS s
ON stp.stage_id = s.id
INNER JOIN source_atomic_sfc.operation_production AS op
ON stp.operation_id = op.id
LEFT JOIN source_atomic.line AS l
ON stp.line_id = l.id
LEFT JOIN dwh.etalent_employees AS ee
ON stp.cod_employee = ee.cod_employee
LEFT JOIN source_atomic_sfc.configuration AS c
ON stp.fingerprint = c.fingerprint
LEFT JOIN (
	    SELECT wp.cust_ord,
	    	CASE WHEN wp.stage = 'CANTOS' THEN 1892 ELSE 2123 END AS operation_id,
           wp.line,
           ROW_NUMBER() OVER (PARTITION BY wp.cust_ord, wp.stage ORDER BY wp.planning_date DESC) AS rn
    FROM source_fast_react.weekly_planning AS wp
    WHERE wp.stage IN ('CANTOS', 'PREENTINTADO')
    AND LEFT(wp.cust_ord, 1) = 'T'
) AS clp
ON sq.cust_ord_hdr_number = clp.cust_ord
AND stp.operation_id = clp.operation_id
AND clp.rn = 1
WHERE op.traceability = 0
AND stp.created_at_short >= CONVERT(date, GETDATE())
GROUP BY CONCAT(stp.cod_employee,' - ', ee.employee_name),
	sq.cust_ord_hdr_number,
	s.name,
	
	CASE
		WHEN stp.operation_id = 1892 AND clp.line IS NOT NULL THEN clp.line
		WHEN stp.operation_id = 1892 AND clp.line IS NULL THEN 'Fuera del Plan'
		WHEN stp.operation_id = 2123 AND clp.line IS NOT NULL THEN clp.line
		WHEN stp.operation_id = 2123 AND clp.line IS NULL THEN 'Fuera del Plan'
		ELSE l.name
	END,
	
	op.operation,
	c.machine_fixed_asset,
	c.group_machine,
	stp.created_at,
	stp.created_at_short

UNION ALL

SELECT CONCAT(strm.cod_employee,' - ', ee.employee_name) AS employee_name,
	STUFF(r.rmi_issuing_cut, 1, 1, 'T') AS cust_ord,
	s.name AS stage,
	l.name AS line,
	orm.operation,
	c.machine_fixed_asset,
	c.group_machine,
	SUM(strm.quantity) AS quantity,
	strm.created_at,
	strm.created_at_short
FROM source_atomic_sfc.scan_transact_rmi AS strm
INNER JOIN source_proaktiv.rmi AS r
ON strm.rmi_ticket = r.rmi_ticket_number
INNER JOIN source_atomic.stage AS s
ON strm.stage_id = s.id
INNER JOIN source_atomic_sfc.operation_rmi AS orm
ON strm.operation_id = orm.id
LEFT JOIN source_atomic.line AS l
ON strm.line_id = l.id
LEFT JOIN dwh.etalent_employees AS ee
ON strm.cod_employee = ee.cod_employee
LEFT JOIN source_atomic_sfc.configuration AS c
ON strm.fingerprint = c.fingerprint
WHERE orm.traceability = 0
AND strm.created_at_short >= CONVERT(date, GETDATE())
GROUP BY CONCAT(strm.cod_employee,' - ', ee.employee_name),
	STUFF(r.rmi_issuing_cut, 1, 1, 'T'),
	s.name,
	l.name,
	orm.operation,
	c.machine_fixed_asset,
	c.group_machine,
	strm.created_at,
	strm.created_at_short