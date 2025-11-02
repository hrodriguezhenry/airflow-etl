SELECT w.year,
	w.week,
	wp.cust_ord,
	MAX(wp.line) AS line,
	
	CASE
		WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
		WHEN wp.stage = 'ENSAMBLE' THEN 'ATRAQUE'
		ELSE wp.stage
	END AS stage,
	
	SUM(wp.quantity) AS planned_quantity,
	wp.planning_date,
	w.last_day_of_week
FROM source_fast_react.weekly_planning AS wp
INNER JOIN source_accesorios.weeks AS w
ON wp.planning_date = w.day
WHERE wp.stage IN ('LAMINADO', 'TROQUEL', 'COSTURA', 'PREENTINTADO', 'CANTOS', 'ENSAMBLE', 'ESFUMADO', 'AZ46', 'PERFORADO', 'SETS')
AND LEFT(wp.cust_ord, 1) = 'T'
AND IIF(wp.line LIKE '%webbing%' AND wp.stage = 'ENSAMBLE', 1, 0) = 0
AND w.day >= CONVERT(date, GETDATE() -14)
GROUP BY w.year,
	w.week,
	wp.cust_ord,
	
	CASE
		WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
		WHEN wp.stage = 'ENSAMBLE' THEN 'ATRAQUE'
		ELSE wp.stage
	END,
	
	wp.planning_date,
	w.last_day_of_week

UNION ALL

SELECT w.year,
	w.week,
	wp.cust_ord,
	
	CASE
		WHEN wp.line LIKE '%10' THEN 'Módulo Línea 10'
		WHEN spq.prints_quantity = 1 THEN 'Módulo 1'
		WHEN spq.prints_quantity = 2 THEN 'Módulo 2'
		WHEN spq.prints_quantity = 3 THEN 'Módulo 3'
		WHEN spq.prints_quantity = 4 THEN 'Módulo 4'
	END AS line,
	
	'ESTAMPADO' AS stage,
	SUM(wp.quantity) AS planned_quantity,
	wp.planning_date,
	w.last_day_of_week
FROM source_fast_react.weekly_planning AS wp
INNER JOIN source_accesorios.weeks AS w
ON wp.planning_date = w.day
LEFT JOIN (
	SELECT srp.style_id,
		COUNT(DISTINCT (s.sfc_operation_id)) AS prints_quantity
	FROM source_atomic_sfc.style_route_production AS srp
	INNER JOIN source_atomic_sfc.sam AS s
	ON srp.sfc_sam_id = s.id
	WHERE srp.active = 1
	AND s.standard_time != 0
	AND s.sfc_operation_id IN (523, 455, 454, 453, 1541, 533, 1207)
	GROUP BY srp.style_id
) AS spq
ON wp.style_id = spq.style_id

WHERE wp.stage = 'ESTAMPADO'
AND LEFT(wp.cust_ord, 1) = 'T'
AND w.day >= CONVERT(date, GETDATE() -14)
GROUP BY w.year,
	w.week,
	wp.cust_ord,
	
	CASE
		WHEN wp.line LIKE '%10' THEN 'Módulo Línea 10'
		WHEN spq.prints_quantity = 1 THEN 'Módulo 1'
		WHEN spq.prints_quantity = 2 THEN 'Módulo 2'
		WHEN spq.prints_quantity = 3 THEN 'Módulo 3'
		WHEN spq.prints_quantity = 4 THEN 'Módulo 4'
	END,
	
	wp.planning_date,
	w.last_day_of_week