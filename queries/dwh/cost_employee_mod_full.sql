SELECT ecm."year",
	ecm."month",
	ecm.week,
	ecm.start_date,
	ecm.end_date,
	ecm.cod_employee,
	p.position,
	ecm.accounting_account,
	ISNULL(pc.cost_center_description, ecm.cost_center_description) AS cost_center_description,
	ecm.cost_center,
	ecm.concept,
	SUM(ecm.amount) AS amount,
	(
	    SELECT AVG(er.exch_rate) AS dollar_exchange_rate
		FROM source_proaktiv.exch_rate AS er
		WHERE er.exch_date BETWEEN ecm.start_date AND ecm.end_date
	) AS dollar_exchange_rate
	
FROM (
	SELECT w.real_year AS "year",
	    w.real_month AS "month",
	    w.week,
	    w.first_day_of_week AS start_date,
		w.last_day_of_week AS end_date,
	    NULL AS cod_employee,
	    j.account AS accounting_account,
	    j.ocr_code_2 AS cost_center,
	    pc.cost_center_description,
	    o.memo AS concept,
	    
	    CASE 
	        WHEN j.debit > 0 THEN j.debit
	        WHEN j.credit > 0 THEN -j.credit
	        ELSE 0 
	    END AS "amount"
	    
	FROM source_sap_tata_go_live.ojdt AS o
	INNER JOIN source_sap_tata_go_live.jdt1 AS j
	ON o.trans_id = j.trans_id
	INNER JOIN source_accesorios.weeks AS w
	ON o.ref_date = w.day
	LEFT JOIN source_etalent.profit_center AS pc
	ON j.ocr_code_2 = pc.cost_center
	WHERE j.account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	AND LEFT(j.ocr_code_2, 1) = '5'
	AND (j.ref_1 IS NULL OR o.memo LIKE 'Liquidación%')
	
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		NULL AS week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdps.cod_employee,
		hdps.accounting_account,
		hdps.cost_center,
		NULL AS cost_center_description,
		CONCAT('Planilla ', hdps.cod_type_payroll) AS concept,
		IIF(hdps."type" = 'DEVENGABLE', hdps.amount, -hdps.amount) AS amount
	FROM source_etalent.historical_data_policy_salary AS hdps
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdps.cod_company = pp.cod_company
	AND hdps.cod_payroll = pp.cod_payroll
	AND hdps.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			MIN(w.day) AS "day"
		FROM source_accesorios.weeks AS w
		GROUP BY w.real_year,
			w.real_month
	) AS dw
	ON dw."day" BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdps.cost_center, 1) = '5'
	AND pp.frequency = 4
	AND hdps.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		dw.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdps.cod_employee,
		hdps.accounting_account,
		hdps.cost_center,
		NULL AS cost_center_description,
		CONCAT('Planilla ', hdps.cod_type_payroll) AS concept,
		IIF(hdps."type" = 'DEVENGABLE', hdps.amount, -1 * hdps.amount) AS amount
	FROM source_etalent.historical_data_policy_salary AS hdps
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdps.cod_company = pp.cod_company
	AND hdps.cod_payroll = pp.cod_payroll
	AND hdps.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			w.week,
			w.first_day_of_week,
			w.last_day_of_week
		FROM source_accesorios.weeks AS w
		WHERE w.day_name = 'DOMINGO'
	) AS dw
	ON dw.first_day_of_week BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdps.cost_center, 1) = '5'
	AND pp.frequency IN (10, 5)
	AND hdps.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		dw.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdps.cod_employee,
		hdps.accounting_account,
		hdps.cost_center,
		NULL AS cost_center_description,
		CONCAT('Contra partida Planilla ', hdps.cod_type_payroll) AS concept,
		hdps.amount AS amount
	FROM source_etalent.historical_data_policy_salary AS hdps
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdps.cod_company = pp.cod_company
	AND hdps.cod_payroll = pp.cod_payroll
	AND hdps.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			w.week,
			w.first_day_of_week,
			w.last_day_of_week
		FROM source_accesorios.weeks AS w
		WHERE w.day_name = 'LUNES'
	) AS dw
	ON dw.first_day_of_week BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdps.cost_center, 1) = '5'
	AND pp.frequency = 11
	AND hdps.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		dw.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdps.cod_employee,
		hdps.accounting_account,
		hdps.cost_center,
		NULL AS cost_center_description,
		CONCAT('Contra partida Planilla ', hdps.cod_type_payroll) AS concept,
		-hdps.amount AS amount
	FROM source_etalent.historical_data_policy_salary AS hdps
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdps.cod_company = pp.cod_company
	AND hdps.cod_payroll = pp.cod_payroll
	AND hdps.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			w.week,
			w.first_day_of_week,
			w.last_day_of_week
		FROM source_accesorios.weeks AS w
		WHERE w.day_name = 'DOMINGO'
	) AS dw
	ON dw.first_day_of_week BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdps.cost_center, 1) = '5'
	AND pp.frequency = 11
	AND hdps.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		NULL AS week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdpp.cod_employee,
		hdpp.accounting_account,
		hdpp.cost_center,
		NULL AS cost_center_description,
		CONCAT('Planilla ', hdpp.cod_type_payroll) AS concept,
		IIF(hdpp."type" = 'DEVENGABLE', hdpp.amount, -1 * hdpp.amount) AS amount
	FROM source_etalent.historical_data_policy_provisions AS hdpp
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdpp.cod_company = pp.cod_company
	AND hdpp.cod_payroll = pp.cod_payroll
	AND hdpp.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			MIN(w.day) AS "day"
		FROM source_accesorios.weeks AS w
		GROUP BY w.real_year,
			w.real_month
	) AS dw
	ON dw."day" BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdpp.cost_center, 1) = '5'
	AND pp.frequency = 4
	AND hdpp.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		dw.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdpp.cod_employee,
		hdpp.accounting_account,
		hdpp.cost_center,
		NULL AS cost_center_description,
		CONCAT('Planilla ', hdpp.cod_type_payroll) AS concept,
		IIF(hdpp."type" = 'DEVENGABLE', hdpp.amount, -hdpp.amount) AS amount
	FROM source_etalent.historical_data_policy_provisions AS hdpp
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdpp.cod_company = pp.cod_company
	AND hdpp.cod_payroll = pp.cod_payroll
	AND hdpp.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			w.week,
			w.first_day_of_week,
			w.last_day_of_week
		FROM source_accesorios.weeks AS w
		WHERE w.day_name = 'DOMINGO'
	) AS dw
	ON dw.first_day_of_week BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdpp.cost_center, 1) = '5'
	AND pp.frequency = 10
	AND hdpp.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		dw.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdpp.cod_employee,
		hdpp.accounting_account,
		hdpp.cost_center,
		NULL AS cost_center_description,
		CONCAT('Contra partida Planilla ', hdpp.cod_type_payroll) AS concept,
		hdpp.amount AS amount
	FROM source_etalent.historical_data_policy_provisions AS hdpp
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdpp.cod_company = pp.cod_company
	AND hdpp.cod_payroll = pp.cod_payroll
	AND hdpp.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			w.week,
			w.first_day_of_week,
			w.last_day_of_week
		FROM source_accesorios.weeks AS w
		WHERE w.day_name = 'LUNES'
	) AS dw
	ON dw.first_day_of_week BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdpp.cost_center, 1) = '5'
	AND pp.frequency = 11
	AND hdpp.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
	
	UNION ALL
	
	SELECT dw.year,
		dw.month,
		dw.week,
		CONVERT(date, pp.start_date) AS start_date,
		CONVERT(date, pp.end_date) AS end_date,
		hdpp.cod_employee,
		hdpp.accounting_account,
		hdpp.cost_center,
		NULL AS cost_center_description,
		CONCAT('Contra partida Planilla ', hdpp.cod_type_payroll) AS concept,
		-hdpp.amount AS amount
	FROM source_etalent.historical_data_policy_provisions AS hdpp
	INNER JOIN source_etalent.payroll_parameters AS pp
	ON hdpp.cod_company = pp.cod_company
	AND hdpp.cod_payroll = pp.cod_payroll
	AND hdpp.cod_type_payroll = pp.cod_type_payroll
	INNER JOIN (
		SELECT w.real_year AS "year",
			w.real_month AS "month",
			w.week,
			w.first_day_of_week,
			w.last_day_of_week
		FROM source_accesorios.weeks AS w
		WHERE w.day_name = 'DOMINGO'
	) AS dw
	ON dw.first_day_of_week BETWEEN pp.start_date AND pp.end_date
	WHERE LEFT(hdpp.cost_center, 1) = '5'
	AND pp.frequency = 11
	AND hdpp.accounting_account IN ('54101001', '54101002', '54101004', '54101005', '54102001', '54102002', '54102003', '54102004', '54102005', '54102012', '54102013')
) AS ecm
LEFT JOIN source_etalent.employee AS e
ON ecm.cod_employee = e.cod_employee
LEFT JOIN source_etalent.position AS p
ON e.cod_company = p.cod_company
AND e.cod_position = p.cod_position
LEFT JOIN source_etalent.position_profit_center AS ppc
ON p.cod_company = ppc.cod_company
AND p.cod_position = ppc.cod_position
LEFT JOIN source_etalent.profit_center AS pc
ON ppc.cod_company = pc.cod_company
AND ppc.cod_profit_center = pc.cod_profit_center
GROUP BY ecm."year",
	ecm."month",
	ecm.week,
	ecm.start_date,
	ecm.end_date,
	ecm.cod_employee,
	p.position,
	ecm.accounting_account,
	ISNULL(pc.cost_center_description, ecm.cost_center_description),
	ecm.cost_center,
	ecm.concept