SELECT ISNULL(am.cod_employee, bm.cod_employee) AS cod_employee,
	ISNULL(am.name, bm.name) AS name,
	ISNULL(am.cost_center_description, bm.cost_center_description) AS cost_center_description,
	ISNULL(am.date, bm.date) AS date,
	am.stage,
	am.line,
	ISNULL(am.scan_production, 'N') AS scan_production,
	ISNULL(bm.biometric_mark, 'N') AS biometric_mark,
	ISNULL(am.week, bm.week) AS week
FROM (
	SELECT m.cod_employee,
		CONCAT(em.first_name, ' ', em.first_last_name) AS name,
		MAX(pca.cost_center_description) AS cost_center_description,
		m.checkin_short AS date,
		MAX(s.name) AS stage,
		MAX(l.name) AS line,
		MAX(IIF(stp.id IS NOT NULL, 'Y', 'N')) AS scan_production,
		w.week
	FROM source_atomic_sfc.mark AS m
	INNER JOIN source_atomic.stage AS s
	ON m.stage_id = s.id
	INNER JOIN source_atomic.line AS l
	ON m.line_id = l.id
	INNER JOIN source_etalent.employee AS em
	ON m.cod_employee = em.cod_employee
	INNER JOIN source_etalent.position_profit_center AS ppca
	ON em.cod_company = ppca.cod_company
	AND em.cod_position = ppca.cod_position
	INNER JOIN source_etalent.profit_center AS pca
	ON ppca.cod_company = pca.cod_company
	AND ppca.cod_profit_center = pca.cod_profit_center
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, m.checkin) = w.day
	LEFT JOIN source_atomic_sfc.group_mark_ref AS gmr
	ON m.id = gmr.mark_id
	LEFT JOIN source_atomic_sfc.scan_transact_production AS stp
	ON gmr.group_mark_id = stp.group_mark_id
	WHERE LEFT(pca.cost_center, 1) = '5'
	GROUP BY m.cod_employee,
		CONCAT(em.first_name, ' ', em.first_last_name),
		m.checkin_short,
		w.week
) AS am

FULL JOIN (
	SELECT cc.cod_employee,
		cc.name,
		MAX(cc.cost_center_description) AS cost_center_description,
		em.access_date_short AS date,
		'Y' biometric_mark,
		w.week
	FROM source_hikvision.employees_mark AS em
	INNER JOIN source_accesorios.weeks AS w
	ON em.access_date_short = w.day
	INNER JOIN (
		SELECT e.cod_employee,
			CONCAT(e.first_name, ' ', e.first_last_name) AS name,
			pc.cost_center_description
		FROM source_etalent.employee AS e
		INNER JOIN source_etalent.position_profit_center AS ppc
		ON e.cod_company = ppc.cod_company
		AND e.cod_position = ppc.cod_position
		INNER JOIN source_etalent.profit_center AS pc
		ON ppc.cod_company = pc.cod_company
		AND ppc.cod_profit_center = pc.cod_profit_center
	) AS cc
	ON CONVERT(VARCHAR(10), em.employee_code) = cc.cod_employee
	WHERE LEFT(cc.cost_center_description, 1) = '5'
	GROUP BY cc.cod_employee,
		cc.name,
		em.access_date_short,
		w.week
) AS bm
ON am.cod_employee = bm.cod_employee
AND am.date = bm.date