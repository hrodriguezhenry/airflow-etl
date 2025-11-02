SELECT wp.cust_ord,
	CASE
		WHEN wp.stage = 'CORTE PIEL' THEN 'CORTE COMBINADO'
		WHEN wp.stage = 'GUILLOTINA' THEN 'CORTE SINTETICO'
		WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
		WHEN wp.stage = 'COSTURA' THEN 'COSTURA CUERPOS'
		WHEN wp.stage = 'ENSAMBLE' THEN 'ATRAQUE'
		ELSE wp.stage
	END AS stage,
	
	MAX(wp.line) AS line,
	SUM(wp.quantity) AS quantity,
	CONVERT(date, wp.planning_date) AS date
FROM source_fast_react.weekly_planning AS wp
WHERE wp.stage IN (
	'CORTE',
	'CORTE PIEL',
	'GUILLOTINA',
	'LAMINADO', 
	'SETS',
	'TROQUEL SETS',
	'ESFUMADO',
	'PERFORADO',
	'PASADORES',
	'TROQUEL',
	'COSTURA',
	'CUERPOS',
	'AZ46',
	'COSTURA OCULTA',
	'CANTOS',
	'PREENTINTADO',
	'ENSAMBLE'
)
AND CONVERT(date, wp.planning_date) >= CONVERT(date, GETDATE() -14)
GROUP BY wp.cust_ord,
	wp.stage,
	wp.planning_date
	
UNION ALL

SELECT wp.cust_ord,
	'ESTAMPADO' AS stage,
	
	CASE
		WHEN wp.line LIKE '%10' THEN 'Módulo Línea 10'
		WHEN spq.prints_quantity = 1 THEN 'Módulo 1'
		WHEN spq.prints_quantity = 2 THEN 'Módulo 2'
		WHEN spq.prints_quantity = 3 THEN 'Módulo 3'
		WHEN spq.prints_quantity = 4 THEN 'Módulo 4'
	END AS line,
	
	SUM(wp.quantity) AS quantity,
	CONVERT(date, wp.planning_date) AS date
FROM source_fast_react.weekly_planning AS wp
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
AND CONVERT(date, wp.planning_date) >= CONVERT(date, GETDATE() -14)
GROUP BY wp.cust_ord,
	
	CASE
		WHEN wp.line LIKE '%10' THEN 'Módulo Línea 10'
		WHEN spq.prints_quantity = 1 THEN 'Módulo 1'
		WHEN spq.prints_quantity = 2 THEN 'Módulo 2'
		WHEN spq.prints_quantity = 3 THEN 'Módulo 3'
		WHEN spq.prints_quantity = 4 THEN 'Módulo 4'
	END,
	
	wp.planning_date
	
UNION ALL

SELECT wp.cust_ord,
	'EMPAQUE' AS stage,
	MAX(wp.line) AS line,
	SUM(wp.quantity) AS quantity,
	CONVERT(date, wp.planning_date) AS date
FROM source_fast_react.weekly_planning AS wp
WHERE wp.stage = 'ENSAMBLE'
AND CONVERT(date, wp.planning_date) >= CONVERT(date, GETDATE() -14)
GROUP BY wp.cust_ord,
	wp.planning_date