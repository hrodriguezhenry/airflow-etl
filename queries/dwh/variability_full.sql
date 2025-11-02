-- DWH_VARIABILITY
-- Update 2023-03-10

-- Consulta que me trae por año, semana, orden, linea y etapa la cantidad de unidades
-- unidaddes planificadas y la cantidad de unidades producidas, mostrando la ultima
-- fecha de planifación para la orden
SELECT cpq.year,
	cpq.week,
	cpq.cust_ord,
	
	CASE
		WHEN cpq.stage = 'ENSAMBLE' AND cpq.line_number IS NULL THEN 'Webbing'
		WHEN cpq.stage = 'CORTE' AND cpq.line_number = 7 THEN 'Corte Webbing'
		WHEN cpq.stage = 'CORTE PIEL' THEN 'Combinado'
		WHEN cpq.stage = 'GUILLOTINA' THEN 'Guillotina'
		WHEN cpq.stage = 'LAMINADO' THEN cpq.line
		WHEN cpq.stage = 'PASADORES' THEN 'Pasadores'
		WHEN cpq.stage = 'TROQUEL' AND cpq.line = '40000 MODULO WEB' THEN 'Webbing'
		WHEN cpq.stage = 'COSTURA' THEN 'Costura'
		ELSE CONCAT('L', cpq.line_number)
	END AS line_id,
	
	cpq.line,
	
	CASE
		WHEN cpq.stage = 'CORTE PIEL' THEN 'CORTE'
		WHEN cpq.stage = 'GUILLOTINA' THEN 'CORTE'
		WHEN cpq.stage = 'LAMINADO' THEN 'PEGADO'
		ELSE cpq.stage
	END AS stage,
	
	cpq.final_planning_date,
	cpq.planned_quantity,
	cpw.weekly_plan_day,
	
	CASE
		WHEN cpq.stage = 'PASADORES' AND cb.quantity_barrettes > 1 THEN v.produced_quantity * cb.quantity_barrettes
		ELSE v.produced_quantity
	END AS produced_quantity

-- Consulta "cpq" que me trae la cantidad de unidades planificadas
-- durante la semana, mostrando la fecha máxima de finalización.
FROM (
	SELECT w.year,
		w.week,
		wpa.cust_ord,
		wpa.line_number,
		wpa.line,
		wpa.stage,
		MAX(w.day) AS final_planning_date,
		SUM(wpa.quantity) AS planned_quantity
	FROM source_fast_react.weekly_planning AS wpa
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, planning_date) = w.day
	GROUP BY w.year,
		w.week,
		wpa.cust_ord,
		wpa.line_number,
		wpa.line,
		wpa.stage
) AS cpq

-- Consulta "cpw" que me trae la sumatoria de la cantidad de unidades
-- planificadas a la fecha actual.
LEFT JOIN (
	SELECT w.year,
		w.week,
		wpa.cust_ord,
		wpa.line_number,
		wpa.stage,
		SUM(wpa.quantity) AS weekly_plan_day
	FROM source_fast_react.weekly_planning AS wpa
	INNER JOIN source_accesorios.weeks AS w
	ON CONVERT(date, planning_date) = w.day
	WHERE w.day < CONVERT(date, GETDATE())
	GROUP BY w.year,
		w.week,
		wpa.cust_ord,
		wpa.line_number,
		wpa.stage
) AS cpw
ON cpq.year = cpw.year
AND cpq.week = cpw.week
AND cpq.cust_ord = cpw.cust_ord
AND cpq.stage = cpw.stage

LEFT JOIN process.variability AS v
ON cpq.year = v.year
AND cpq.week = v.week
AND cpq.cust_ord = v.cust_ord
AND CASE
	WHEN cpq.stage = 'CORTE PIEL' THEN 'CORTE'
	WHEN cpq.stage = 'GUILLOTINA' THEN 'CORTE'
	WHEN cpq.stage = 'LAMINADO' THEN 'PEGADO'
	ELSE cpq.stage
END  = v.stage

LEFT JOIN (
	SELECT DISTINCT pso.cust_ord,
		pso.quantity_barrettes
	FROM dwh.proaktiv_sales_orders AS pso
) AS cb
ON cpq.cust_ord = cb.cust_ord