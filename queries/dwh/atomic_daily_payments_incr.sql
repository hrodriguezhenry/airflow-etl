SELECT edhb.id,
    edhb.day AS date,
    edhb.cod_employee,
    edhb.name AS employee_name,
    edhb.efficiency_area_id,
    ISNULL(ea.name, 'NA') AS efficiency_area,
    edhb.time_worked,
    edhb.time_with_worked,
    edhb.efficiency,
    edhb.efficiency_setup,
    edhb.time_setup,
    edhb.time_lunch,
    edhb.time_factor,
    ISNULL(cwu.wasted_units, 0) AS wasted_units,
    ISNULL(cru.rejected_units, 0) AS rejected_units,
    edhb.amount AS efficiency_amount,
    
	CASE ea.type_qa
        WHEN 'waste-unit' THEN IIF(edhb.amount <= 0, 0, IIF(cwu.wasted_units > ISNULL(ea.limit_daily_units, 0), 0, edhb.amount))
        WHEN 'reject-unit' THEN IIF(edhb.amount <= 0, 0, IIF(cru.rejected_units > ISNULL(ea.limit_daily_units, 0), 0, edhb.amount))
        WHEN 'reject-percent' THEN IIF(cru.amount IS NOT NULL, cru.amount, edhb.amount)
        WHEN 'waste-percent' THEN IIF(cwu.amount IS NOT NULL, cwu.amount, edhb.amount)
        WHEN 'combined' THEN IIF(edhb.amount <= 0, 0, IIF(cwu.amount IS NOT NULL, cwu.amount, IIF(cru.amount IS NOT NULL, cru.amount, edhb.amount)))
        ELSE 0
    END / cdegq.group_quantity AS final_amount,
    
    CASE ea.type_qa
        WHEN 'waste-unit' THEN IIF(edhb.amount <= 0, 0, IIF(cwu.wasted_units > ISNULL(ea.limit_daily_units, 0), edhb.amount, 0))
        WHEN 'reject-unit' THEN IIF(edhb.amount <= 0, 0, IIF(cru.rejected_units > ISNULL(ea.limit_daily_units, 0), edhb.amount, 0))
        WHEN 'reject-percent' THEN ISNULL(cru.qa_amount, 0)
        WHEN 'waste-percent' THEN ISNULL(cwu.qa_amount, 0)
        WHEN 'combined' THEN ISNULL(cru.qa_amount, 0) + ISNULL(cwu.qa_amount, 0)
    END AS discounted_amount,
    
    cdegq.group_quantity
FROM source_atomic_bonus.efficiency_daily_history AS edhb
LEFT JOIN source_atomic_bonus.efficiency_area AS ea
ON edhb.efficiency_area_id = ea.id

LEFT JOIN (
	SELECT edhw.cod_employee,
		edhw.day,
		SUM(edhw.inspection_wasted_qty) AS wasted_units,
		SUM(edhw.amount) AS amount,
		SUM(edhw.expected_amount) - SUM(edhw.amount) AS qa_amount
	FROM source_atomic_bonus.efficiency_daily_history_waste AS edhw
	WHERE edhw.day >= CONVERT(date, GETDATE() -14)
	GROUP BY edhw.cod_employee,
		edhw.day
) AS cwu
ON edhb.cod_employee = cwu.cod_employee
AND edhb.day = cwu.day

LEFT JOIN (
	SELECT edhr.cod_employee,
		edhr.day,
		SUM(edhr.inspection_rejected_qty) AS rejected_units,
		SUM(edhr.amount) AS amount,
		SUM(edhr.expected_amount) - SUM(amount) AS qa_amount
	FROM source_atomic_bonus.efficiency_daily_history_reject AS edhr
	WHERE edhr.day >= CONVERT(date, GETDATE() -14)
	GROUP BY edhr.cod_employee,
		edhr.day
) as cru
ON edhb.cod_employee = cru.cod_employee
AND edhb.day = cru.day

LEFT JOIN (
	SELECT edha.cod_employee,
		edha.day,
		edha.efficiency_area_id,
		MAX(cdgq.group_quantity) AS group_quantity
	FROM source_atomic_bonus.efficiency_daily_history AS edha
	LEFT JOIN (
		SELECT edh.cod_employee,
			edh.day,
			COUNT(1) AS group_quantity
		FROM source_atomic_bonus.efficiency_daily_history AS edh
		WHERE edh.efficiency_area_id IS NOT NULL
		AND edh.expected_amount > 0
		GROUP BY edh.cod_employee,
			edh.day
	) AS cdgq
	ON edha.cod_employee = cdgq.cod_employee
	AND edha.day = cdgq.day
	WHERE edha.efficiency_area_id IS NOT NULL
	AND edha.expected_amount > 0
	AND cdgq.day >= CONVERT(date, GETDATE() -14)
	GROUP BY edha.cod_employee,
		edha.day,
		edha.efficiency_area_id
) AS cdegq
ON cdegq.cod_employee = edhb.cod_employee
AND cdegq.day = edhb.day
AND cdegq.efficiency_area_id = edhb.efficiency_area_id
WHERE ea.daily = 1
AND edhb.day >= CONVERT(date, GETDATE() -14)