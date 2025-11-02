-- DWH_ETALENT_EMPLOYEES_PENDING_DAYS
-- Update 2025-10-02

SELECT e.cod_employee,
	e.full_name AS employee_full_name,
	p.area,
	p.position,
	pc.cost_center,
	
	CASE
		WHEN CHARINDEX(CONCAT(pc.cost_center, '-'), pc.cost_center_description) > 0
		THEN REPLACE(pc.cost_center_description, CONCAT(pc.cost_center, '-'), '')
		WHEN CHARINDEX(CONCAT(pc.cost_center, ' - '), pc.cost_center_description) > 0
		THEN REPLACE(pc.cost_center_description, CONCAT(pc.cost_center, ' - '), '')
		WHEN CHARINDEX(CONCAT(pc.cost_center, ' '), pc.cost_center_description) > 0
		THEN REPLACE(pc.cost_center_description, CONCAT(pc.cost_center, ' '), '')
		ELSE NULL
	END AS departament,
	
	ea.cod_employee AS cod_supervisor,
	ea.full_name AS supervisor_name,
	CONVERT(date, e.entry_date) AS entry_date,
	
	(
		(CAST(15 AS DECIMAL(19, 10)) / CAST(365 AS DECIMAL(19, 10))) *
		DATEDIFF(
			DAY,
			e.entry_date,
			DATEADD(
				YEAR, 
				(DATEDIFF(YEAR, e.entry_date, GETDATE() + 1) - IIF(FORMAT(e.entry_date, 'MMdd') > FORMAT(GETDATE(), 'MMdd'), 1, 0)),
				e.entry_date
			)
		)
	)
	-ISNULL(vc.vacation_consumed, 0) AS pending_days,
	
	'N' AS delete_row
	
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
LEFT JOIN (
	SELECT v.cod_company,
		v.cod_employee,
		SUM(v.days) AS vacation_consumed
	FROM source_etalent.vacation AS v
	GROUP BY v.cod_company,
		v.cod_employee
) AS vc
ON e.cod_company = vc.cod_company
AND e.cod_employee = vc.cod_employee
WHERE e.cod_company = 1
AND e.status = 'A'
AND p.area IN ('MOD', 'MOI', 'PAD')