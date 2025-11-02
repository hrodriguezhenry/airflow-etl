SELECT cop.year,
	cop.week,
	cop.planning_date,
	DATEPART(weekday, cop.planning_date) AS day_number,
	cop.cust_ord,
	cop.line,
	cop.stage,
	costl.quantity AS requerid_quantity,
	cop.planned_quantity,
	ISNULL(clstp.total_planned_quantity, 0) AS total_planned_quantity,
	ISNULL(ctdq.total_dispatch_quantity, 0) AS total_dispatch_quantity,
	ISNULL(ctaq.total_available_quantity, 0) AS total_available_quantity,
	cop.last_day_of_week
FROM process.stage_traffic_planning AS cop
INNER JOIN analysis.customer_order_style_layer AS costl
ON cop.cust_ord = costl.cust_ord

INNER JOIN (
	SELECT copb."year",
		copb.week,
		copb.planning_date,
		copa.cust_ord,
		copa.stage,
		SUM(copa.planned_quantity) AS total_planned_quantity
	FROM process.stage_traffic_planning AS copa
	INNER JOIN process.stage_traffic_planning AS copb
	ON copa.cust_ord = copb.cust_ord
	AND copa.stage = copb.stage
	AND copa.planning_date <= copb.planning_date
	GROUP BY copb.year,
		copb.week,
		copb.planning_date,
		copa.cust_ord,
		copa.stage
) AS clstp
ON cop.planning_date = clstp.planning_date
AND cop.cust_ord = clstp.cust_ord
AND cop.stage = clstp.stage

LEFT JOIN (
	SELECT copa.year,
		copa.week,
		cop.cust_ord,
		cop.stage,
		SUM(cop.quantity) AS total_dispatch_quantity
	FROM process.stage_traffic_production AS cop
	INNER JOIN (
		SELECT copz.year,
			copz.week,
			copz.cust_ord,
			copz.stage,
			copz.last_day_of_week
		FROM process.stage_traffic_planning AS copz
		GROUP BY copz.year,
			copz.week,
			copz.cust_ord,
			copz.stage,
			copz.last_day_of_week
	) AS copa
	ON cop.cust_ord = copa.cust_ord
	AND cop.stage = copa.stage
	AND cop.last_day_of_week <= copa.last_day_of_week	
	WHERE cop.operation = 'dispatch'
	GROUP BY copa.year,
		copa.week,
		cop.cust_ord,
		cop.stage
) AS ctdq
ON cop.year = ctdq.year
AND cop.week = ctdq.week
AND cop.cust_ord = ctdq.cust_ord
AND cop.stage = ctdq.stage

LEFT JOIN (
	SELECT copb.year,
		copb.week,
		cop.cust_ord,
		cop.stage,
		SUM(cop.quantity) AS total_available_quantity
	FROM process.stage_traffic_production AS cop
	INNER JOIN (
		SELECT copy.year,
			copy.week,
			copy.cust_ord,
			copy.stage,
			copy.last_day_of_week
		FROM process.stage_traffic_planning AS copy
		GROUP BY copy.year,
			copy.week,
			copy.cust_ord,
			copy.stage,
			copy.last_day_of_week
	) AS copb
	ON cop.cust_ord = copb.cust_ord
	AND cop.stage = copb.stage
	AND cop.last_day_of_week <= copb.last_day_of_week
	WHERE cop.operation = 'reception'
	GROUP BY copb.year,
		copb.week,
		cop.cust_ord,
		cop.stage
) AS ctaq
ON cop.year = ctaq.year
AND cop.week = ctaq.week
AND cop.cust_ord = ctaq.cust_ord
AND cop.stage = ctaq.stage

WHERE cop.last_day_of_week >= CONVERT(date, GETDATE() -14)