WITH production AS (
	SELECT w.year,
		w.week,
		sq.cust_ord_hdr_number AS cust_ord,
		stp.operation_id,
		sr.print_route,
		sr.seam_route,
		stp.quantity,
		w.last_day_of_week
	FROM source_atomic_sfc.scan_transact_production AS stp
	INNER JOIN source_atomic_sfc.scan_qr AS sq
	ON stp.sfc_scan_qr_id = sq.id
	INNER JOIN source_accesorios.weeks AS w
	ON stp.created_at_short = w.day
	LEFT JOIN (
		SELECT srp.style_id,
			MAX(CASE WHEN op.stage_id = 46 THEN 1 END) AS print_route,
			MAX(CASE WHEN op.stage_id = 5 THEN 1 END) AS seam_route
		FROM source_atomic_sfc.style_route_production AS srp
		INNER JOIN source_atomic_sfc.sam AS s
		ON srp.sfc_sam_id = s.id
		INNER JOIN source_atomic_sfc.operation_production AS op
		ON s.sfc_operation_id = op.id
		WHERE op.stage_id IN (46, 5)
		GROUP BY srp.style_id
	) AS sr
	ON sr.style_id = sq.style_id
	WHERE stp.operation_id IN (2002, 1884, 1879, 1765, 2123, 1892, 1821, 1995, 2003, 1996, 1998, 1885, 1893, 2000, 1890, 1891, 2108, 2190)
	AND stp.quantity != 0
)

SELECT os.year,
	os.week,
	os.cust_ord,
	os.stage,
	os.operation,
	SUM(os.quantity) AS quantity,
	os.last_day_of_week
FROM (
	SELECT p.year,
		p.week,
		p.cust_ord,
		
		CASE
			WHEN p.operation_id = 1884 THEN 'TROQUEL'
			WHEN p.operation_id = 1765 THEN 'PREENTINTADO'
			WHEN p.operation_id = 2123 THEN 'CANTOS'
			WHEN p.operation_id = 1821 THEN 'ATRAQUE'
			WHEN p.operation_id = 1996 THEN 'ESFUMADO'
			WHEN p.operation_id = 1998 THEN 'AZ46'
			WHEN p.operation_id = 2000 THEN 'PERFORADO'
			WHEN p.operation_id = 1885 THEN 'ESTAMPADO'
			WHEN p.operation_id = 1893 THEN 'COSTURA'
			WHEN p.operation_id = 2190 THEN 'SETS'
		END AS stage,
		
		'dispatch' AS operation,
		p.quantity,
		p.last_day_of_week
	FROM production AS p
	WHERE p.operation_id IN (1884, 1765, 2123, 1821, 1996, 1998, 2000, 1885, 1893, 2190)
	
	UNION ALL
	
	SELECT p.year,
		p.week,
		p.cust_ord,
		
		CASE
			WHEN p.operation_id = 2002 THEN 'TROQUEL'
			WHEN p.operation_id = 1879 THEN 'PREENTINTADO'
			WHEN p.operation_id = 1765 THEN 'CANTOS'
			WHEN p.operation_id = 1892 THEN 'ATRAQUE'
			WHEN p.operation_id = 2108 THEN 'SETS'
			WHEN p.operation_id IN (1995, 2003, 1890, 1891) THEN so.stage
		END AS stage,
		
		'reception' AS operation,
		p.quantity,
		p.last_day_of_week
	FROM production AS p
	LEFT JOIN (
		SELECT 'ESFUMADO' AS stage, 1995 AS operation_id UNION ALL
		SELECT 'ESFUMADO' AS stage, 2003 AS operation_id UNION ALL
		SELECT 'AZ46' AS stage, 1995 AS operation_id UNION ALL
		SELECT 'AZ46' AS stage, 2003 AS operation_id UNION ALL
		SELECT 'PERFORADO' AS stage, 1995 AS operation_id UNION ALL
		SELECT 'PERFORADO' AS stage, 2003 AS operation_id UNION ALL
		SELECT 'ESTAMPADO' AS stage, 1890 AS operation_id UNION ALL
		SELECT 'COSTURA' AS stage, 1890 AS operation_id UNION ALL
		SELECT 'COSTURA' AS stage, 1891 AS operation_id
	) AS so
	ON p.operation_id = so.operation_id
	WHERE p.operation_id IN (2002, 1879, 1765, 1892, 1995, 2003, 1890, 1891, 2108)
	AND CASE
			WHEN p.print_route IS NULL AND so.stage = 'ESTAMPADO' THEN 0
			WHEN p.seam_route IS NULL AND so.stage = 'COSTURA' THEN 0
			WHEN p.print_route IS NOT NULL AND p.operation_id = 1890 AND so.stage = 'COSTURA' THEN 0
			ELSE 1
		END = 1
) AS os
GROUP BY os.year,
	os.week,
	os.cust_ord,
	os.stage,
	os.operation,
	os.last_day_of_week