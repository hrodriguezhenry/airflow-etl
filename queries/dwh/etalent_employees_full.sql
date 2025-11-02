-- DWH_ETALENT_EMPLOYEES
-- Update 2023-08-18

SELECT e.cod_employee,
	e.first_name + ' ' + e.first_last_name AS employee_name,
	e.full_name AS employee_full_name,
	p.area,
	p.position,
	e.status,
	pc.cost_center,
	pc.cost_center_description,
	
	CASE
		WHEN CHARINDEX(CONCAT(pc.cost_center, '-'), pc.cost_center_description) > 0
		THEN REPLACE(pc.cost_center_description, CONCAT(pc.cost_center, '-'), '')
		WHEN CHARINDEX(CONCAT(pc.cost_center, ' - '), pc.cost_center_description) > 0
		THEN REPLACE(pc.cost_center_description, CONCAT(pc.cost_center, ' - '), '')
		WHEN CHARINDEX(CONCAT(pc.cost_center, ' '), pc.cost_center_description) > 0
		THEN REPLACE(pc.cost_center_description, CONCAT(pc.cost_center, ' '), '')
		ELSE null
	END AS departament,
	
	ea.cod_employee AS cod_supervisor,
	ea.full_name AS supervisor_name,
	rl.cod_reason_liquidation,
	rl.name AS reason_liquidation,
	td.type_departure,
	e.entry_date,
	e.retirement_date,
	CASE
		WHEN e.gender = 1 THEN 'Masculino'
		WHEN e.gender = 2 THEN 'Femenino'
		ELSE NULL
	END AS gender,

	e.birthdate,

	CASE
		WHEN e.marital_status = 1 THEN 'Soltero/a'
		WHEN e.marital_status = 2 THEN 'Casado/a'
		WHEN e.marital_status = 3 THEN 'Unido/a'
		WHEN e.marital_status = 4 THEN 'Separado/a'
		WHEN e.marital_status = 5 THEN 'Divorciado/a'
		WHEN e.marital_status = 6 THEN 'Viudo/a'
		ELSE NULL
	END AS marital_status,
	
	e.number_children
	
FROM source_etalent.employee AS e
LEFT JOIN source_etalent.position AS p
ON e.cod_company = p.cod_company
AND e.cod_position = p.cod_position
LEFT JOIN source_etalent.employee AS ea
ON p.supervisor_cod_position = ea.cod_position
AND ea.status = 'A'
LEFT JOIN source_etalent.position_profit_center AS ppc
ON p.cod_company = ppc.cod_company
AND p.cod_position = ppc.cod_position
LEFT JOIN source_etalent.profit_center AS pc
ON ppc.cod_company = pc.cod_company
AND ppc.cod_profit_center = pc.cod_profit_center
LEFT JOIN source_etalent.reason_liquidation AS rl
ON e.cod_company = rl.cod_company
AND rl.cod_reason_liquidation = e.cod_reason_liquidation
LEFT JOIN source_automate.type_departure AS td
ON rl.cod_reason_liquidation = td.cod_reason_liquidation
WHERE e.cod_company = 1