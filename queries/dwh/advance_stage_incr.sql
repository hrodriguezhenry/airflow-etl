SELECT w.year,
	w.week,
	ISNULL(apr.cust_ord, apl.cust_ord) AS cust_ord,
	
	CASE
		WHEN apr.production_prefix IS NULL AND apl.stage = 'ATRAQUE' THEN 'EM'
		WHEN apr.production_prefix IS NULL AND apl.stage = 'CORTE' THEN 'S'
		WHEN apr.production_prefix IS NULL AND apl.stage = 'CORTE COMBINADO' THEN 'S'
		WHEN apr.production_prefix IS NULL AND apl.stage = 'CORTE SINTETICO' THEN 'S'
		WHEN apr.production_prefix IS NULL AND apl.stage = 'EMPAQUE' THEN 'EM'
		WHEN apr.production_prefix IS NULL THEN 'T'
		ELSE apr.production_prefix
	END AS production_prefix,
	
	ISNULL(apr.stage, apl.stage) AS stage,
	ISNUll(apl.line, ISNULL(apr.line, 'Fuera del Plan')) AS line,
	apl.quantity AS planned_quantity,
	apr.quantity AS produced_quantity,
	w.day AS date,
	w.first_day_of_week
	
FROM (
	SELECT aspr.cust_ord,
		aspr.stage,
		aspr.production_prefix,
		aspr.quantity,
		pw.line,
		aspr.date,
		wa.first_day_of_week
	FROM process.advance_stage_production AS aspr
	INNER JOIN source_accesorios.weeks AS wa
	ON aspr.date = wa.day
	
	LEFT JOIN (
		SELECT aspl.cust_ord,
			aspl.stage,
			MAX(aspl.line) AS line,
			w.first_day_of_week
		FROM process.advance_stage_planning AS aspl
		INNER JOIN source_accesorios.weeks AS w
		ON aspl.date BETWEEN w.first_day_of_week AND DATEADD(DAY, 14, w.last_day_of_week)
		AND w.day >= CONVERT(date, GETDATE() -21)
		GROUP BY aspl.cust_ord,
			aspl.stage,
			w.first_day_of_week
	) AS pw
	ON aspr.cust_ord = pw.cust_ord
	AND aspr.stage = pw.stage
	AND wa.first_day_of_week = pw.first_day_of_week
	
	WHERE aspr.date >= CONVERT(date, GETDATE() -21)
) AS apr

FULL JOIN (
	SELECT aspl.cust_ord,
		aspl.stage,
		MAX(aspl.line) AS line,
		SUM(aspl.quantity) AS quantity,
		aspl.date
	FROM process.advance_stage_planning AS aspl
	WHERE aspl.date >= CONVERT(date, GETDATE() -21)
	GROUP BY aspl.cust_ord,
		aspl.stage,
		aspl.date
) AS apl
ON apr.cust_ord = apl.cust_ord
AND apr.stage = apl.stage
AND apr.date = apl.date

INNER JOIN source_accesorios.weeks AS w
ON ISNULL(apr.date, apl.date) = w.day

WHERE w.day >= CONVERT(date, GETDATE() -21)