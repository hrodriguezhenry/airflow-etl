SELECT CONCAT(stp.cod_employee,' - ', ee.employee_name) AS employee_name,
	sq.cust_ord_hdr_number AS cust_ord,
	s.name AS stage,
	l.name AS line,
	op.operation,
	c.machine_fixed_asset,
	c.group_machine,
	SUM(stp.quantity) AS quantity,
	stp.created_at,
	stp.created_at_short
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
WHERE op.traceability = 0
GROUP BY CONCAT(stp.cod_employee,' - ', ee.employee_name),
	sq.cust_ord_hdr_number,
	s.name,
	l.name,
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
GROUP BY CONCAT(strm.cod_employee,' - ', ee.employee_name),
	STUFF(r.rmi_issuing_cut, 1, 1, 'T'),
	s.name,
	l.name,
	orm.operation,
	c.machine_fixed_asset,
	c.group_machine,
	strm.created_at,
	strm.created_at_short