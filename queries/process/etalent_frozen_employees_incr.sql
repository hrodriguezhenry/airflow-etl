-- PROCESS.ETALENT_FROZEN_EMPLOYEES
-- Update 2024-01-09

-- Consulta que me trae a los empleados
-- con su centro de costo historico en cierto año y semana.
SELECT w.year,
	w.week,
	ph.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name) AS name,
	p.position,
	u.cost_center,
	ph.cost_center_description,
	w.first_day_of_week
FROM source_etalent.employee AS e
INNER JOIN source_etalent.position AS p
ON e.cod_company = p.cod_company
AND e.cod_position = p.cod_position
INNER JOIN source_etalent.payroll_history AS ph
ON e.cod_company = ph.cod_company
AND e.cod_employee = ph.cod_employee
INNER JOIN source_etalent.unit AS u
ON ph.cod_company = u.cod_company
AND ph.cod_unit = u.cod_unit
INNER JOIN source_etalent.payroll_parameters AS pp
ON ph.cod_company = pp.cod_company
AND ph.cod_payroll = pp.cod_payroll
AND ph.cod_type_payroll = pp.cod_type_payroll
INNER JOIN source_accesorios.weeks AS w
ON pp.start_date =  w.day
WHERE CONVERT(date, pp.end_date) < CONVERT(date, GETDATE())
AND w.first_day_of_week >= (
	SELECT wa.first_day_of_week
	FROM source_accesorios.weeks AS wa
	WHERE wa.day = CONVERT(date, GETDATE())
)
GROUP BY w.year,
	w.week,
	ph.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name),
	p.position,
	u.cost_center,
	ph.cost_center_description,
	w.first_day_of_week

UNION ALL

-- Consulta que me trae a los empleados
-- con su centro de costo en la semana y año actual.
SELECT w.year,
	w.week,
	e.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name) AS name,
	p.position,
	pc.cost_center,
	pc.cost_center_description,
	w.first_day_of_week
FROM source_etalent.employee AS e
INNER JOIN source_etalent.position AS p
ON e.cod_company = p.cod_company
AND e.cod_position = p.cod_position
INNER JOIN source_etalent.position_profit_center AS ppc
ON p.cod_company = ppc.cod_company
AND p.cod_position = ppc.cod_position
INNER JOIN source_etalent.profit_center AS pc
ON ppc.cod_company = pc.cod_company
AND ppc.cod_profit_center = pc.cod_profit_center
INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, GETDATE()) = w.day
WHERE e.status = 'A'
AND w.first_day_of_week >= (
	SELECT wa.first_day_of_week
	FROM source_accesorios.weeks AS wa
	WHERE wa.day = CONVERT(date, GETDATE())
)
GROUP BY w.year,
	w.week,
	e.cod_employee,
	CONCAT(e.first_name, ' ', e.first_last_name),
	p.position,
	pc.cost_center,
	pc.cost_center_description,
	w.first_day_of_week