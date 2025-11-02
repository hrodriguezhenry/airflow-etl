SELECT w.year,
	w.week,
	w.day AS date,
	'orders' AS nesting_type,
	REPLACE(m.material_file, '.hid', '') AS ticket_number,
	s.name AS bill,
	j.name AS job,
	l.name AS layout_name,
	m.session_id,
	m.batch_id,
	m.length AS material_length,
	m.width AS material_width,
	l.length AS layout_length,
	l.width AS layout_width,
	l.acquired_mat_area AS acquired_material_area,
	l.declared_mat_area AS declared_material_area,
	l.yield,
	l.num_instances AS number_instances,
	l.instances_area,
	l.declared_instances_area,
	l.nest_duration,
	l.nest_date AS nesting_creation_date
FROM source_nesting_orders.materials AS m
INNER JOIN source_nesting_orders.sessions AS s
ON m.session_id = s.session_id
INNER JOIN source_nesting_orders.jobs AS j
ON s.job_id = j.job_id
INNER JOIN source_nesting_orders.layouts AS l
ON m.material_id = l.material_id
AND s.session_id = l.session_id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, nest_date) = w.day

UNION ALL

SELECT w.year,
	w.week,
	w.day AS date,
	'bills' AS nesting_type,
	REPLACE(m.material_file, '.hid', '') AS ticket_number,
	s.name AS bill,
	j.name AS job,
	l.name AS layout_name,
	m.session_id,
	m.batch_id,
	m.length AS material_length,
	m.width AS material_width,
	l.length AS layout_length,
	l.width AS layout_width,
	l.acquired_mat_area AS acquired_material_area,
	l.declared_mat_area AS declared_material_area,
	l.yield,
	l.num_instances AS number_instances,
	l.instances_area,
	l.declared_instances_area,
	l.nest_duration,
	l.nest_date AS nesting_creation_date
FROM source_nesting_bills.materials AS m
INNER JOIN source_nesting_bills.sessions AS s
ON m.session_id = s.session_id
INNER JOIN source_nesting_bills.jobs AS j
ON s.job_id = j.job_id
INNER JOIN source_nesting_bills.layouts AS l
ON m.material_id = l.material_id
AND s.session_id = l.session_id
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, nest_date) = w.day