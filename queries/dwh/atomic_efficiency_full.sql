SELECT ae.*,
	qtyp.quantity_p
FROM (
	SELECT w.year,
		CONVERT(date, ec.check_in) AS date,
		w.week,
		ec.cod_employee,
		CONCAT(e.first_name, ' ', 
		e.first_surname) name,
		e.position,
		e.cost_center,
		e.cost_center_description,
		ec.operation_id,
		ec.operation_name AS operation,
		ec.line_id,
		ec.line_name AS line, 
		ec.stage_id,
		ec.stage_name AS stage,
		ec.layout_station_id,
		ec.layout_station_name AS layout_station,
		SUM(ec.quantity) AS quantity,
		SUM(ec.time_worked) AS time_worked,
		SUM(ec.time_out) AS time_out,
		SUM(ec.time_lunch) AS time_lunch,
		SUM(ec.time_event) AS time_event,
		SUM(ec.time_featured) AS time_featured, 
		SUM(ec.time_off_standard) AS time_off_standard,
		SUM(ec.time_with_worked) AS time_with_worked,
		SUM(ec.time_with_worked_qr) AS time_with_worked_qr
	FROM source_atomic_sfc.efficiency_consolidated AS ec
	JOIN source_etalent.employees e
	ON ec.cod_employee=e.code_employee
	JOIN source_accesorios.weeks w
	ON CONVERT(date, ec.check_in) = w.day
	GROUP BY w.year,
		CONVERT(date, ec.check_in),
		w.week,
		ec.cod_employee,
		CONCAT(e.first_name, ' ', 
		e.first_surname),
		e.position,
		e.cost_center,
		e.cost_center_description,
		ec.operation_id,
		ec.operation_name,
		ec.line_id,
		ec.line_name, 
		ec.stage_id,
		ec.stage_name,
		ec.layout_station_id,
		ec.layout_station_name
	) AS ae

INNER JOIN (
	SELECT operation.date,
		operation.stage_id,
		operation.line_id,
		operation.operation_id,
		CONVERT(DECIMAL, ISNULL(production.quantity, 0))/operation.cnt AS quantity_p
		
	FROM (
		SELECT ae.date,
			ae.stage_id,
			ae.line_id,
			ae.operation_id,
			SUM(1) AS cnt
		
		FROM (
			SELECT CONVERT(date, ec.check_in) AS date,
				ec.cod_employee,
				ec.operation_id,
				ec.line_id,
				ec.stage_id
			FROM source_atomic_sfc.efficiency_consolidated AS  ec
			GROUP BY CONVERT(date, ec.check_in),
				ec.cod_employee,
				ec.operation_id,
				ec.line_id,
				ec.stage_id
			) AS ae
			
		GROUP BY ae.date,
			ae.stage_id,
			ae.line_id,
			ae.operation_id
		) AS operation
	
	LEFT JOIN (
		SELECT CONVERT(date, stp.created_at) AS date,
			stp.stage_id,
			stp.line_id,
			stp.operation_id,
			SUM(stp.quantity) AS quantity
		FROM source_atomic_sfc.scan_transact_production AS stp
		GROUP BY CONVERT(date, stp.created_at),
			stp.stage_id,
			stp.line_id,
			stp.operation_id
		) AS production
		
	ON operation.date = production.date
		AND operation.stage_id = production.stage_id
		AND operation.line_id = production.line_id
		AND operation.operation_id = production.operation_id
	) AS qtyp

ON ae.date = qtyp.date
	AND ae.stage_id = qtyp.stage_id
	AND ae.line_id = qtyp.line_id
	AND ae.operation_id = qtyp.operation_id

ORDER BY ae.date