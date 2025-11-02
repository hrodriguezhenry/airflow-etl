-- DWH_ETALENT_HEAD_COUNT
-- Update 2023-03-09

-- Consulta que me trae por centro de costo
-- la cantidad actual y la cantidad estandar
-- de personal que debería de existir
SELECT ccs.year,
	ccs.week,
	ccs.start_date,
	ccs.end_date,
	ccs.cost_center,
	ccs.cost_center_description,
	SUM(ccs.current_head_count) AS current_head_count,
	SUM(ccs.standard_head_count) AS standard_head_count
	
FROM (
	-- Consulta que me trae el historico de la cantidad 
	-- de empleados que tuvieron un pago de frecuencia semanal
	-- por centro de costo.
	SELECT w.year,
		w.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		u.cost_center,
		ph.cost_center_description,
		COUNT(ph.cod_position) AS current_head_count,
		0 AS standard_head_count
	FROM source_etalent.payroll_history AS ph
	INNER JOIN source_etalent.unit AS u
	ON ph.cod_company = u.cod_company
	AND ph.cod_unit = u.cod_unit
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON ph.cod_company = pp.cod_company
	AND ph.cod_payroll = pp.cod_payroll
	AND ph.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN source_accesorios.weeks AS w
	ON pp.start_date =  w.day
	WHERE pp.frequency = 10
	AND CONVERT(date, pp.end_date) < CONVERT(date, GETDATE())
	GROUP BY w.year,
		w.week,
		CONVERT(date, pp.start_date),
		CONVERT(date, pp.end_date),
		u.cost_center,
		ph.cost_center_description
	
	UNION ALL
	
	-- Consulta que me trae la cantidad de empleados activos
	-- y que además tienen un pago de frecuencia semanal
	-- por centro de costo.
	SELECT w.year,
		w.week,
		w.first_day_of_week AS start_date,
		w.last_day_of_week AS end_date,
		pc.cost_center,
		pc.cost_center_description,
		COUNT(p.cod_position) AS current_head_count,
		0 AS standard_head_count
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
	INNER JOIN source_etalent.type_payroll AS tp
	ON e.cod_company = tp.cod_company
	AND e.cod_type_payroll = tp.cod_type_payroll
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, GETDATE()) = w.day
	WHERE e.status = 'A'
	AND tp.type = 'S7'
	GROUP BY w.year,
		w.week,
		w.first_day_of_week,
		w.last_day_of_week,
		pc.cost_center,
		pc.cost_center_description
	
	UNION ALL
	
	SELECT shc.year,
		shc.week,
		CONVERT(date, shc.start_date) AS start_date,
		CONVERT(date, shc.end_date) AS end_date,
		shc.cost_center,
		ISNULL(edc.cost_center_description, SHC.cost_center_description) AS cost_center_description,
		0 AS current_head_count,
		shc.standard_head_count
	FROM source_automate.standard_head_count AS shc
	
	-- Consulta edc que me trae la descripcion del centro de costo
	-- actualizado
	LEFT JOIN (
		SELECT DISTINCT CONVERT(date, pp.end_date) AS end_date,
			u.cost_center,
			ph.cost_center_description
		FROM source_etalent.payroll_history AS ph
		INNER JOIN source_etalent.unit AS u
		ON ph.cod_company = u.cod_company
		AND ph.cod_unit = u.cod_unit
		INNER JOIN source_etalent.payroll_parameters AS pp
		ON ph.cod_company = pp.cod_company
		AND ph.cod_payroll = pp.cod_payroll
		AND ph.cod_type_payroll =  pp.cod_type_payroll
		WHERE pp.frequency = 10
		AND CONVERT(date, pp.end_date) < CONVERT(date, GETDATE())
		
		UNION
		
		SELECT DISTINCT w.last_day_of_week AS end_date,
			pc.cost_center AS cost_center,
			pc.cost_center_description
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
	) AS edc
	ON CONVERT(date, shc.end_date) = edc.end_date
	AND shc.cost_center = edc.cost_center
) AS ccs
GROUP BY ccs.year,
	ccs.week,
	ccs.start_date,
	ccs.end_date,
	ccs.cost_center,
	ccs.cost_center_description