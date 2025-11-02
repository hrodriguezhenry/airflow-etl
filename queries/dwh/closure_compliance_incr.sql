WITH cust_ord_planning AS (
	SELECT w.year,
		w.week,
		wp.cust_ord,
		
		CASE
			WHEN wp.stage = 'ENSAMBLE' THEN 'ATRAQUE'
			WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
			ELSE wp.stage
		END AS stage,
		
		MAX(wp.line) AS line,
		MAX(wp.planning_date) AS planning_date,
		SUM(wp.quantity) AS planned_quantity,
		cosl.quantity AS requerid_quantity,
		w.first_day_of_week
	FROM source_fast_react.weekly_planning AS wp
	INNER JOIN source_accesorios.weeks AS w
	ON wp.planning_date = w.day
	INNER JOIN analysis.customer_order_style_layer AS cosl
	ON wp.cust_ord = cosl.cust_ord
	WHERE wp.stage IN ('CORTE', 'LAMINADO', 'TROQUEL', 'COSTURA', 'CANTOS', 'ENSAMBLE')
	AND LEFT(wp.cust_ord, 1) = 'T'
	GROUP BY w.year,
		w.week,
		wp.cust_ord,
		
		CASE
			WHEN wp.stage = 'ENSAMBLE' THEN 'ATRAQUE'
			WHEN wp.stage = 'LAMINADO' THEN 'PEGADO'
			ELSE wp.stage
		END,
		
		cosl.quantity,
		w.first_day_of_week
	
	UNION ALL
	
	SELECT w.year,
		w.week,
		wp.cust_ord,
		'ESTAMPADO' AS stage,

		CASE
			WHEN wp.line LIKE '%10' THEN 'Módulo Línea 10'
			WHEN spq.prints_quantity = 1 THEN 'Módulo 1'
			WHEN spq.prints_quantity = 2 THEN 'Módulo 2'
			WHEN spq.prints_quantity = 3 THEN 'Módulo 3'
			WHEN spq.prints_quantity = 4 THEN 'Módulo 4'
		END AS line,
		
		MAX(wp.planning_date) AS planning_date,
		SUM(wp.quantity) AS planned_quantity,
		cosl.quantity AS requerid_quantity,
		w.first_day_of_week
	FROM source_fast_react.weekly_planning AS wp
	INNER JOIN source_accesorios.weeks AS w
	ON wp.planning_date = w.day
	INNER JOIN analysis.customer_order_style_layer AS cosl
	ON wp.cust_ord = cosl.cust_ord
	
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
		cosl.quantity,
		w.first_day_of_week
),

cust_ord_production AS (
	SELECT sq.cust_ord_hdr_number AS cust_ord,
		CASE
			WHEN stp.operation_id = 1890 THEN 'TROQUEL'
			WHEN stp.operation_id = 1891 THEN 'ESTAMPADO'
			WHEN stp.operation_id = 1894 THEN 'COSTURA'
			WHEN stp.operation_id = 1892 THEN 'CANTOS'
			WHEN stp.operation_id = 936 THEN 'ATRAQUE'
		END AS stage,
		SUM(stp.quantity) AS quantity,
		w.first_day_of_week
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN source_accesorios.weeks AS w
	ON stp.created_at_short = w.day
	WHERE stp.operation_id IN (1890, 1891, 1894, 1892, 936)
	GROUP BY sq.cust_ord_hdr_number,
		stp.operation_id,
		w.first_day_of_week
	
	UNION ALL
	
	SELECT cosl.cust_ord,
		s.name AS stage,
		SUM(ps.quantity) AS quantity,
		w.first_day_of_week
	FROM source_atomic_sfc.production_scan AS ps
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON ps.sfc_scan_qr_id = sq.id
	INNER JOIN analysis.customer_order_style_layer AS cosl
	ON sq.cust_ord_hdr_number = cosl.cust_ord
	INNER JOIN source_atomic.stage AS s
	ON ps.stage_id = s.id
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, ps.created_at) = w.day
	
	WHERE
		CASE
			WHEN ps.stage_id = 3 AND ps.scan_type = 2 THEN 'Y'
			WHEN ps.stage_id = 2 AND ps.scan_type = 2 AND cosl.layers = 1 THEN 'Y'
			ELSE 'N'
		END = 'y'
	GROUP BY cosl.cust_ord,
		s.name,
		w.first_day_of_week
)

SELECT copl.year,
	copl.week,
	copl.cust_ord,
	copl.stage,
	copl.line,
	copl.planning_date,
	1 AS planned_closure,
	IIF(ISNULL(csqt.produced_quantity, 0) >= copl.requerid_quantity, 1, 0) AS ralized_closure,
	copl.first_day_of_week
	
FROM cust_ord_planning AS copl

LEFT JOIN (
	SELECT copa.cust_ord,
		copa.stage,
		SUM(copa.quantity) AS produced_quantity,
		copb.first_day_of_week
	FROM cust_ord_production AS copa
	INNER JOIN cust_ord_planning AS copb
	ON copa.cust_ord = copb.cust_ord
	AND copa.stage = copb.stage
	AND copa.first_day_of_week < copb.first_day_of_week
	GROUP BY copa.cust_ord,
		copa.stage,
		copb.first_day_of_week
) AS csq
ON copl.cust_ord = csq.cust_ord
AND copl.stage = csq.stage
AND copl.first_day_of_week = csq.first_day_of_week

LEFT JOIN (
	SELECT copa.cust_ord,
		copa.stage,
		SUM(copa.quantity) AS produced_quantity,
		copb.first_day_of_week
	FROM cust_ord_production AS copa
	INNER JOIN cust_ord_planning AS copb
	ON copa.cust_ord = copb.cust_ord
	AND copa.stage = copb.stage
	AND copa.first_day_of_week <= copb.first_day_of_week
	GROUP BY copa.cust_ord,
		copa.stage,
		copb.first_day_of_week
) AS csqt
ON copl.cust_ord = csqt.cust_ord
AND copl.stage = csqt.stage
AND copl.first_day_of_week = csqt.first_day_of_week

WHERE (copl.planned_quantity + ISNULL(csq.produced_quantity, 0)) >= copl.requerid_quantity
AND copl.first_day_of_week > (
	SELECT w.first_day_of_week
	FROM source_accesorios.weeks AS w
	WHERE w.day = CONVERT(date, GETDATE() -14)
)