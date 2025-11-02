WITH on_time_date AS (
    SELECT otp.cust_ord,
        otp.planning_stage,
        otp.stage,
        otp.line,
        otp.planning_date,
        otp.planning_week,
        otp.produced_quantity,
        otp.required_quantity,
        otp.total_layers,
        otp.scan_date,
        otp.scan_week,
        otp.first_day_of_week,
        CASE
            WHEN otp.stage IN ('CORTE', 'PEGADO', 'SETS', 'CANTOS', 'PREENTINTADO', 'TROQUEL SETS') THEN DATEADD(DAY, +2, otp.planning_date)
            WHEN otp.stage IN ('TROQUEL','ESTAMPADO', 'COSTURA', 'CUERPOS', 'AZ46', 'PERFORADO', 'ESFUMADO') THEN DATEADD(DAY, +1, otp.planning_date)
            ELSE DATEADD(DAY, +3, otp.planning_date)
        END AS extra_deadline
    FROM process.on_time_stage AS otp

    UNION ALL

    SELECT otd.cust_ord,
        otd.planning_stage,
        otd.stage,
        otd.line,
        otd.planning_date,
        otd.planning_week,
        otd.produced_quantity,
        otd.required_quantity,
        otd.total_layers,
        otd.scan_date,
        otd.scan_week,
        otd.first_day_of_week,
        DATEADD(DAY, 1, otd.extra_deadline) AS extra_deadline
    FROM on_time_date AS otd
    WHERE DATEPART(dw, otd.extra_deadline) IN (1, 7)
    OR otd.extra_deadline IN (
		SELECT w.day FROM source_accesorios.weeks AS w
		WHERE DATEPART(dw, w.day) NOT IN (1, 7) AND w.laboral_day = 'N'
	)
),

on_time AS (
	SELECT cust_ord,
	    planning_stage,
	    stage,
	    line,
	    planning_date,
	    MAX(extra_deadline) AS extra_deadline,
	    planning_week,
	    produced_quantity,
	    required_quantity,
	    total_layers,
	    scan_date,
	    scan_week,
	    first_day_of_week
	FROM on_time_date
	GROUP BY 
	    cust_ord, planning_stage, stage, line, planning_date, planning_week, produced_quantity, 
	    required_quantity, total_layers, scan_date, scan_week, first_day_of_week
)


SELECT dots.cust_ord,
	dots.planning_stage,
	dots.stage,
	dots.line,
	dots.planning_date,
	dots.extra_deadline,
	dots.produced_quantity,
	dots.required_quantity,
	dots.total_layers,
	dots.scan_date,
	dots.scan_week,
	dots.first_day_of_week,
	
	CASE
		WHEN dots.scan_date <= dots.extra_deadline AND dots.produced_quantity >= dots.required_quantity THEN 'EN TIEMPO'
    	WHEN dots.scan_date > dots.extra_deadline AND dots.produced_quantity >= dots.required_quantity THEN 'TARDE'
    	WHEN w.day <= DATEADD(DAY, 7, dots.first_day_of_week) AND w.day <= dots.extra_deadline
			AND dots.produced_quantity < dots.required_quantity THEN 'EN PROCESO'
    	WHEN w.day <= DATEADD(DAY, 7, dots.first_day_of_week) AND w.day > dots.extra_deadline
			AND dots.produced_quantity < dots.required_quantity THEN 'NO REALIZADA'
    	WHEN dots.scan_date IS NULL AND dots.produced_quantity >= dots.required_quantity THEN 'REPLANIFICADO'
	    ELSE 'NO APLICA' 
	END status,
	
	GETDATE() AS "current_time"
	
FROM (
	SELECT pot.cust_ord,
		pot.planning_stage,
		pot.stage,
		pot.line,
		pot.planning_date,
		
		CASE
			WHEN csef.extra_deadline IS NOT NULL AND pot.planning_date >= csef.extra_deadline THEN pot.planning_date
			WHEN otd.extra_deadline IS NOT NULL AND pot.planning_date >= otd.extra_deadline THEN pot.planning_date
			ELSE ISNULL(otd.extra_deadline, pot.extra_deadline)
		END AS extra_deadline,
		
		pot.planning_week,
		pot.produced_quantity,
		pot.required_quantity,
		pot.total_layers,
		pot.scan_date,
		pot.scan_week,
		pot.first_day_of_week
		
	FROM on_time AS pot
	
	LEFT JOIN (
	    SELECT ot.cust_ord,
	    	ot.stage,
	    	ot.extra_deadline,
	    	DATEADD(DAY, 7, ot.first_day_of_week) AS first_day_of_week
	    FROM on_time AS ot
		WHERE DATEPART(dw, ot.extra_deadline) IN (3,4)
		AND ot.produced_quantity < ot.required_quantity
	) otd
	ON pot.cust_ord = otd.cust_ord
	AND pot.stage = otd.stage
	AND pot.first_day_of_week = otd.first_day_of_week
	
	LEFT JOIN (
	    SELECT ot.cust_ord,
	    	ot.stage,
	    	ot.extra_deadline,
	    	DATEADD(DAY, 7, ot.first_day_of_week) AS first_day_of_week
	    FROM on_time AS ot
		WHERE DATEPART(dw, ot.extra_deadline) IN (2, 5, 6, 7)
		AND ot.produced_quantity < ot.required_quantity
	) AS csef
	ON pot.cust_ord = csef.cust_ord
	AND pot.stage = csef.stage
	AND pot.first_day_of_week = csef.first_day_of_week
) AS dots

INNER JOIN source_accesorios.weeks AS w
ON CONVERT(date, GETDATE()-7) = w.day

WHERE CASE
    WHEN w.day_name = 'LUNES' THEN DATEADD(DAY, -7, w.first_day_of_week)
    ELSE w.first_day_of_week
END <= dots.first_day_of_week